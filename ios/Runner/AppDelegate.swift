import Flutter
import UIKit
import ExternalAccessory

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(_ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "DriveMapObd") {
      DriveMapObd.register(with: registrar)
    }
  }
}

/// The MX+ uses MFi ExternalAccessory. Protocol identifiers must be obtained
/// from OBD Solutions and declared in UISupportedExternalAccessoryProtocols.
final class DriveMapObd: NSObject, FlutterPlugin, FlutterStreamHandler, StreamDelegate {
  private var sink: FlutterEventSink?
  private var session: EASession?
  private var pending = Data()
  private var opening: FlutterResult?
  private var openStreams = Set<ObjectIdentifier>()
  private var timeout: DispatchWorkItem?
  private var disconnectObserver: NSObjectProtocol?

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = DriveMapObd()
    registrar.addMethodCallDelegate(instance,
      channel: FlutterMethodChannel(name: "drivemap/obd", binaryMessenger: registrar.messenger()))
    FlutterEventChannel(name: "drivemap/obd_bytes", binaryMessenger: registrar.messenger()).setStreamHandler(instance)
    EAAccessoryManager.shared().registerForLocalNotifications()
    instance.disconnectObserver = NotificationCenter.default.addObserver(
      forName: .EAAccessoryDidDisconnect, object: nil, queue: .main) { [weak instance] note in
        guard let self = instance,
          let accessory = note.userInfo?[EAAccessoryKey] as? EAAccessory,
          accessory.connectionID == self.session?.accessory?.connectionID else { return }
        self.fail("L’adattatore OBD si è disconnesso.")
    }
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "devices":
      result(EAAccessoryManager.shared().connectedAccessories.map {
        ["id": String($0.connectionID), "name": $0.name, "paired": true] as [String: Any]
      })
    case "pairing":
      EAAccessoryManager.shared().showBluetoothAccessoryPicker(withNameFilter: nil) { error in
        DispatchQueue.main.async {
          if let error = error { result(FlutterError(code: "pairing", message: error.localizedDescription, details: nil)) }
          else { result(nil) }
        }
      }
    case "connect":
      close()
      let args = call.arguments as? [String: Any]
      guard let id = args?["id"] as? String,
        let accessory = EAAccessoryManager.shared().connectedAccessories.first(where: { String($0.connectionID) == id }) else {
        result(FlutterError(code: "device", message: "Associa OBDLink MX+ nelle impostazioni Bluetooth e aggiorna l’elenco.", details: nil)); return
      }
      let allowed = Bundle.main.object(forInfoDictionaryKey: "UISupportedExternalAccessoryProtocols") as? [String] ?? []
      guard let proto = accessory.protocolStrings.first(where: { allowed.contains($0) }) else {
        result(FlutterError(code: "mfi_configuration", message: "Configurazione iOS necessaria: richiedi a OBD Solutions il protocollo MFi e l’abilitazione dell’app, poi configura UISupportedExternalAccessoryProtocols.", details: nil)); return
      }
      guard let connection = EASession(accessory: accessory, forProtocol: proto),
        let input = connection.inputStream, let output = connection.outputStream else {
        result(FlutterError(code: "session", message: "Sessione MFi non disponibile. Chiudi le altre app OBD e verifica l’abilitazione del produttore.", details: nil)); return
      }
      session = connection
      opening = result
      for stream in [input as Stream, output as Stream] {
        stream.delegate = self
        stream.schedule(in: .main, forMode: .common)
        stream.open()
      }
      let work = DispatchWorkItem { [weak self] in self?.fail("Apertura del collegamento MFi scaduta.") }
      timeout = work
      DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: work)
    case "write":
      guard session != nil, let data = call.arguments as? FlutterStandardTypedData else {
        result(FlutterError(code: "disconnected", message: "OBD disconnesso.", details: nil)); return
      }
      guard pending.count + data.data.count < 32768 else {
        result(FlutterError(code: "buffer", message: "Buffer Bluetooth pieno.", details: nil)); return
      }
      pending.append(data.data)
      flush()
      result(nil)
    case "disconnect": close(); result(nil)
    default: result(FlutterMethodNotImplemented)
    }
  }

  func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
    switch eventCode {
    case .openCompleted:
      openStreams.insert(ObjectIdentifier(aStream))
      if openStreams.count == 2 {
        timeout?.cancel(); timeout = nil
        let done = opening; opening = nil
        UIApplication.shared.isIdleTimerDisabled = true
        done?(nil)
      }
    case .hasBytesAvailable:
      guard let input = session?.inputStream else { return }
      var buffer = [UInt8](repeating: 0, count: 4096)
      while input.hasBytesAvailable {
        let count = input.read(&buffer, maxLength: buffer.count)
        if count < 0 { fail("Errore di lettura Bluetooth."); return }
        if count == 0 { break }
        sink?(FlutterStandardTypedData(bytes: Data(buffer.prefix(count))))
      }
    case .hasSpaceAvailable: flush()
    case .errorOccurred, .endEncountered: fail(aStream.streamError?.localizedDescription ?? "Connessione interrotta.")
    default: break
    }
  }

  private func flush() {
    guard let output = session?.outputStream else { return }
    while output.hasSpaceAvailable && !pending.isEmpty {
      let count = pending.withUnsafeBytes { raw -> Int in
        guard let bytes = raw.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return 0 }
        return output.write(bytes, maxLength: raw.count)
      }
      if count < 0 { fail("Errore di scrittura Bluetooth."); return }
      if count == 0 { return }
      pending.removeFirst(count)
    }
  }

  private func fail(_ message: String) {
    let error = FlutterError(code: "connection", message: message, details: nil)
    let callback = opening; opening = nil
    callback?(error)
    sink?(error)
    close()
  }

  private func close() {
    timeout?.cancel(); timeout = nil
    let callback = opening; opening = nil
    callback?(FlutterError(code: "cancelled", message: "Connessione annullata.", details: nil))
    if let session = session {
      for stream in [session.inputStream as Stream?, session.outputStream as Stream?].compactMap({ $0 }) {
        stream.delegate = nil; stream.close(); stream.remove(from: .main, forMode: .common)
      }
    }
    session = nil; pending.removeAll(); openStreams.removeAll()
    UIApplication.shared.isIdleTimerDisabled = false
  }
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? { sink = events; return nil }
  func onCancel(withArguments arguments: Any?) -> FlutterError? { sink = nil; return nil }
  deinit {
    timeout?.cancel()
    if let observer = disconnectObserver { NotificationCenter.default.removeObserver(observer) }
  }
}
