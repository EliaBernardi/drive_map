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
  String pidStatus = 'PID non ancora verificati';
  String protocol = '';
  String? error;
  String? ecu;
  Set<int> supportedPids = {};
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
    if (log.length > 5000) log.removeAt(0);
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
      _log('Errore lettura dispositivi associati: $error');
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
    _log('Avvio ricerca Bluetooth Classic');
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
        if (previous.isEmpty) {
          _log(
            'Dispositivo rilevato: ${device.name.isEmpty ? '(nome non disponibile)' : device.name} ($id)',
          );
        }
        _update();
      },
      onError: (Object e) {
        error = readableError(e);
        _log('Errore stream ricerca Bluetooth: $error');
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
      _log('Ricerca Bluetooth Classic attiva');
    } catch (e) {
      error = readableError(e);
      _log('Errore ricerca: $error');
      await stopScan();
    }
  }

  Future<void> stopScan() async {
    ++_scanGeneration;
    if (!scanning && _discovery == null) return;
    final wasScanning = scanning;
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
      _log('Errore arresto ricerca Bluetooth: $error');
    }
    if (!busy && !connected) status = 'Ricerca terminata';
    if (wasScanning) _log('Ricerca Bluetooth terminata');
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
    pidStatus = 'PID non ancora verificati';
    supportedPids = {};
    ecu = null;
    protocol = '';
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
      await _identifyAndDiscover(token);
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
      await _identifyAndDiscover(_generation);
    } catch (e) {
      error = readableError(e);
      _log('Errore: $error');
      await _disconnect(statusAfter: 'Collegamento da ripristinare');
    } finally {
      busy = false;
      _update();
    }
  }

  Future<String> _request(String command, {Duration? timeout}) async {
    _log('→ $command');
    final response = await _channel!.request(
      command,
      timeout: timeout ?? const Duration(seconds: 8),
    );
    final cleaned = response.trim();
    _log(
      '← ${cleaned.isEmpty ? '(risposta vuota)' : cleaned.replaceAll(RegExp(r'[\r\n]+'), ' | ')}',
    );
    return cleaned;
  }

  Future<void> _identifyAndDiscover(int token) async {
    final response = await _request('ATI');
    if (token != _generation) return;
    if (response.isEmpty || response.toUpperCase().contains('?')) {
      throw const ObdException('Risposta ATI non valida.');
    }
    status = 'Adattatore identificato · ricerca PID in corso';
    pidStatus = 'Configuro l’adattatore e interrogo la centralina…';
    _update();
    await _discoverPids(token);
  }

  Future<void> _discoverPids(int token) async {
    try {
      for (final command in [
        'ATE0',
        'ATL0',
        'ATS1',
        'ATH1',
        'ATSP0',
        'ATAT1',
        'ATST64',
      ]) {
        final response = await _request(command);
        if (token != _generation) return;
        if (!response.toUpperCase().contains('OK')) {
          throw ObdException('L’adattatore non ha confermato $command.');
        }
      }

      pidStatus = 'Interrogo i PID standard (01–20)…';
      _update();
      final firstResponse = await _request(
        '0100',
        timeout: const Duration(seconds: 18),
      );
      if (token != _generation) return;
      final firstReplies = PidDecoder.replies(firstResponse, 0);
      if (firstReplies.isEmpty) {
        pidStatus = PidDecoder.noData(firstResponse)
            ? 'La centralina non ha risposto a 0100 (NO DATA).'
            : 'Nessuna risposta OBD valida a 0100.';
        status = 'Adattatore connesso · centralina non rilevata';
        _log(pidStatus);
        _update();
        return;
      }

      final primary = firstReplies.firstWhere(
        (reply) => reply.ecu == '7E8' || reply.ecu == '18DAF110',
        orElse: () => firstReplies.first,
      );
      ecu = primary.ecu;
      final codes = PidDecoder.supported(primary.bytes, 0);
      for (
        var base = 0x20;
        base <= 0xE0 && codes.contains(base);
        base += 0x20
      ) {
        final command =
            '01${base.toRadixString(16).padLeft(2, '0').toUpperCase()}';
        pidStatus = 'Interrogo i PID ${base + 1}–${base + 0x20}…';
        _update();
        final pageResponse = await _request(
          command,
          timeout: const Duration(seconds: 12),
        );
        if (token != _generation) return;
        final page = PidDecoder.replies(
          pageResponse,
          base,
        ).where((reply) => reply.ecu == ecu).firstOrNull;
        if (page == null) {
          _log('La centralina $ecu non ha fornito la bitmap di $command.');
          break;
        }
        try {
          codes.addAll(PidDecoder.supported(page.bytes, base));
        } on FormatException catch (e) {
          _log('Bitmap incompleta per $command: $e');
          break;
        }
      }
      if (token != _generation) return;
      codes.removeWhere(
        (code) => code >= 0x20 && code <= 0xE0 && code % 0x20 == 0,
      );
      supportedPids = Set.unmodifiable(codes);
      protocol = (await _request('ATDP'))
          .replaceAll(RegExp(r'[\r\n]+'), ' ')
          .trim();
      if (token != _generation) return;
      pidStatus = supportedPids.isEmpty
          ? 'Nessun PID standard supportato rilevato.'
          : '${supportedPids.length} PID standard rilevati sulla centralina $ecu.';
      status = 'Adattatore identificato';
      _log('$pidStatus${protocol.isEmpty ? '' : ' · protocollo $protocol'}');
      _update();
    } catch (e) {
      if (token != _generation) return;
      pidStatus = 'Verifica PID non completata: ${readableError(e)}';
      status = 'Adattatore connesso · verifica PID incompleta';
      _log(pidStatus);
      _update();
    }
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
