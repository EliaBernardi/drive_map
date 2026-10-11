import 'dart:async';

import 'package:flutter/foundation.dart';

import 'elm_protocol.dart';
import 'obd_transport.dart';

/// Bluetooth Classic discovery, pairing, RFCOMM and one ELM identity request.
class AdapterCheck extends ChangeNotifier {
  AdapterCheck({ObdTransport? transport})
    : _transport = transport ?? PlatformObdTransport();

  final ObdTransport _transport;
  ElmChannel? _channel;
  StreamSubscription<Object>? _linkErrors;
  StreamSubscription<Map<String, dynamic>>? _discovery;
  Timer? _scanTimer;
  Future<void>? _closing;
  int _generation = 0;
  int _scanGeneration = 0;
  bool busy = false;
  bool connected = false;
  bool scanning = false;
  bool showDevices = false;
  bool onlyObdLink = true;
  String status = 'Disconnesso';
  String? error;
  ObdDevice? selected;
  List<ObdDevice> devices = [];
  List<ObdDevice> nearby = [];
  final List<String> log = [];
  bool _disposed = false;

  void _update() {
    if (!_disposed) notifyListeners();
  }

  void _log(String message) {
    log.add('${DateTime.now().toLocal().toIso8601String()}  $message');
    if (log.length > 100) log.removeAt(0);
    _update();
  }

  Future<void> refreshDevices() async {
    if (busy) return;
    busy = true;
    error = null;
    _update();
    try {
      devices = await PlatformObdTransport.devices();
      if (!devices.any((device) => device.id == selected?.id)) selected = null;
    } catch (e) {
      error = readableError(e);
    } finally {
      busy = false;
      _update();
    }
  }

  Future<void> openPairing() => PlatformObdTransport.pairing();

  List<ObdDevice> get visibleDevices {
    final byId = <String, ObdDevice>{
      for (final device in devices) device.id: device,
      for (final device in nearby) device.id: device,
    };
    return byId.values
        .where(
          (device) =>
              !onlyObdLink || device.name.toLowerCase().startsWith('obdlink'),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  void setObdLinkFilter(bool enabled) {
    onlyObdLink = enabled;
    _update();
  }

  Future<void> scan() async {
    if (busy || scanning || connected) return;
    final token = ++_scanGeneration;
    error = null;
    nearby = [];
    scanning = true;
    showDevices = true;
    status = 'Ricerca Bluetooth in corso…';
    _update();
    _discovery = PlatformObdTransport.discovery.listen(
      (event) {
        if (event['type'] == 'finished') {
          unawaited(stopScan());
          return;
        }
        if (event['type'] != 'device') return;
        final id = event['id'] as String?;
        if (id == null) return;
        final name = event['name'] as String? ?? '';
        final previous = nearby.where((device) => device.id == id);
        final device = ObdDevice(
          id,
          name.isNotEmpty
              ? name
              : (previous.isNotEmpty ? previous.first.name : ''),
          paired: event['paired'] as bool? ?? false,
        );
        nearby = [
          for (final item in nearby)
            if (item.id != id) item,
          device,
        ];
        _update();
      },
      onError: (Object e) {
        error = readableError(e);
        unawaited(stopScan());
      },
    );
    try {
      await PlatformObdTransport.scan();
      if (token != _scanGeneration) {
        await PlatformObdTransport.stopScan();
        return;
      }
      devices = await PlatformObdTransport.devices();
      if (token != _scanGeneration) return;
      _scanTimer = Timer(
        const Duration(seconds: 25),
        () => unawaited(stopScan()),
      );
      _log('Ricerca Bluetooth Classic avviata');
    } catch (e) {
      error = readableError(e);
      _log('Errore ricerca: $error');
      await stopScan();
    }
  }

  Future<void> stopScan() async {
    ++_scanGeneration;
    if (!scanning && _discovery == null) return;
    scanning = false;
    _scanTimer?.cancel();
    _scanTimer = null;
    final discovery = _discovery;
    _discovery = null;
    await discovery?.cancel();
    try {
      await PlatformObdTransport.stopScan();
    } catch (e) {
      error ??= readableError(e);
    }
    if (!busy && !connected) status = 'Ricerca terminata';
    _update();
  }

  void select(ObdDevice? device) {
    if (busy || connected) return;
    selected = device;
    error = null;
    _update();
  }

  Future<void> selectAndConnect(ObdDevice device) async {
    select(device);
    await connect();
  }

  Future<void> connect() async {
    final device = selected;
    if (busy || connected || device == null) return;
    final token = ++_generation;
    busy = true;
    error = null;
    status = 'Connessione a ${device.name}…';
    _update();
    _log('Connessione RFCOMM/SPP a ${device.name} (${device.id})');
    try {
      await stopScan();
      if (token != _generation) return;
      if (!device.paired) {
        status =
            'Associazione a ${device.name}… Conferma la richiesta Android.';
        _update();
        _log('Associazione richiesta per ${device.name}');
        await PlatformObdTransport.bond(device.id)
            .timeout(const Duration(seconds: 50));
        if (token != _generation) return;
        selected = ObdDevice(device.id, device.name);
        devices = [
          for (final item in devices)
            if (item.id != device.id) item,
          selected!,
        ];
        _log('Dispositivo associato');
      }
      status = 'Connessione a ${device.name}…';
      _update();
      _linkErrors = _transport.bytes.listen(
        (_) {},
        onError: (Object e) => _lost(token, readableError(e)),
        onDone: () => _lost(token, 'Collegamento Bluetooth interrotto.'),
      );
      _channel = ElmChannel(_transport);
      await _transport.connect(device.id).timeout(const Duration(seconds: 20));
      if (token != _generation) return;
      connected = true;
      status = 'Connesso a ${device.name}';
      _update();
      _log('Socket RFCOMM connesso');
      await _identify(token);
    } catch (e) {
      if (token == _generation) {
        error = readableError(e);
        _log('Errore: $error');
        await _disconnect(statusAfter: 'Connessione non riuscita');
      }
    } finally {
      if (token == _generation) {
        busy = false;
        _update();
      }
    }
  }

  Future<void> identify() async {
    if (busy || !connected) return;
    busy = true;
    error = null;
    _update();
    try {
      await _identify(_generation);
    } catch (e) {
      error = readableError(e);
      _log('Errore: $error');
      await _disconnect(statusAfter: 'Collegamento da ripristinare');
    } finally {
      busy = false;
      _update();
    }
  }

  Future<void> _identify(int token) async {
    _log('→ ATI');
    final response = await _channel!.request(
      'ATI',
      timeout: const Duration(seconds: 8),
    );
    if (token != _generation) return;
    final cleaned = response.trim();
    _log(
      '← ${cleaned.isEmpty ? '(risposta vuota)' : cleaned.replaceAll(RegExp(r'[\r\n]+'), ' | ')}',
    );
    if (cleaned.isEmpty || cleaned.toUpperCase().contains('?')) {
      throw const ObdException('Risposta ATI non valida.');
    }
    status = 'Adattatore identificato';
    _update();
  }

  void _lost(int token, String reason) {
    if (token != _generation) return;
    error = reason;
    _log('Collegamento interrotto: $reason');
    unawaited(_disconnect(statusAfter: 'Disconnesso'));
  }

  Future<void> disconnect() => _disconnect(statusAfter: 'Disconnesso');

  Future<void> _disconnect({required String statusAfter}) {
    final closing = _closing;
    if (closing != null) return closing;
    final future = _performDisconnect(statusAfter: statusAfter);
    _closing = future;
    return future.whenComplete(() => _closing = null);
  }

  Future<void> _performDisconnect({required String statusAfter}) async {
    ++_generation;
    connected = false;
    busy = true;
    status = 'Disconnessione…';
    _update();
    await stopScan();
    final channel = _channel;
    _channel = null;
    await channel?.close();
    final errors = _linkErrors;
    _linkErrors = null;
    await errors?.cancel();
    try {
      await PlatformObdTransport.cancelBond();
    } catch (_) {
      // The socket must still be closed if the activity is already gone.
    }
    try {
      await _transport.disconnect();
    } catch (e) {
      error ??= readableError(e);
    }
    busy = false;
    status = statusAfter;
    _log('Socket chiuso');
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(disconnect());
    super.dispose();
  }
}
