import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/telemetry.dart';
import 'elm_protocol.dart';
import 'obd_transport.dart';

class PidTestSpec {
  const PidTestSpec(this.code, this.label, this.unit);

  final int code;
  final String label;
  final String unit;
  String get hex => code.toRadixString(16).padLeft(2, '0').toUpperCase();
  String get command => '01$hex';
}

class PidTestResult {
  const PidTestResult({
    required this.code,
    required this.label,
    required this.unit,
    required this.latest,
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.validSamples,
    required this.failedSamples,
  });

  final int code;
  final String label;
  final String unit;
  final double? latest;
  final double? average;
  final double? minimum;
  final double? maximum;
  final int validSamples;
  final int failedSamples;
  String get hex => code.toRadixString(16).padLeft(2, '0').toUpperCase();
}

class _PidTestAccumulator {
  _PidTestAccumulator(this.spec);

  final PidTestSpec spec;
  double? latest;
  double? minimum;
  double? maximum;
  double total = 0;
  int validSamples = 0;
  int failedSamples = 0;

  void add(double value) {
    latest = value;
    minimum = minimum == null || value < minimum! ? value : minimum;
    maximum = maximum == null || value > maximum! ? value : maximum;
    total += value;
    validSamples++;
  }

  PidTestResult get result => PidTestResult(
    code: spec.code,
    label: spec.label,
    unit: spec.unit,
    latest: latest,
    average: validSamples == 0 ? null : total / validSamples,
    minimum: minimum,
    maximum: maximum,
    validSamples: validSamples,
    failedSamples: failedSamples,
  );
}

final List<PidTestSpec> _pidTestSpecs = List.unmodifiable([
  for (final pid in Pid.values) PidTestSpec(pid.code, pid.label, pid.unit),
  const PidTestSpec(0x2F, 'Livello carburante', '%'),
  const PidTestSpec(0x62, 'Coppia motore effettiva', '%'),
  const PidTestSpec(0x63, 'Coppia motore di riferimento', 'Nm'),
  const PidTestSpec(0xA6, 'Contachilometri totale', 'km'),
]);

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
  bool pidTestRunning = false;
  double pidTestProgress = 0;
  String? pidTestMessage;
  final Map<int, _PidTestAccumulator> _pidTestResults = {};
  Stopwatch? _pidTestClock;
  Timer? _pidTestTicker;
  int _pidTestRun = 0;
  bool _cancelPidTestRequested = false;
  DateTime? _lastConsumptionIntegration;
  double? _testSpeedKph;
  double? _testFuelRateLph;
  double _testDistanceKm = 0;
  double _testFuelLiters = 0;
  bool _disposed = false;

  List<PidTestSpec> get testablePids => _pidTestSpecs
      .where((spec) => supportedPids.contains(spec.code))
      .toList(growable: false);
  List<PidTestResult> get pidTestResults => [
    for (final spec in _pidTestSpecs)
      if (_pidTestResults[spec.code] case final accumulator?)
        accumulator.result,
  ];
  int get pidTestElapsedSeconds =>
      ((_pidTestClock?.elapsedMilliseconds ?? 0) / 1000).floor().clamp(0, 30);
  double get testDistanceKm => _testDistanceKm;
  double get testFuelLiters => _testFuelLiters;
  double? get averageConsumptionLPer100Km =>
      _testDistanceKm < 0.005 ? null : _testFuelLiters * 100 / _testDistanceKm;

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
    _pidTestResults.clear();
    pidTestProgress = 0;
    pidTestMessage = null;
    _testDistanceKm = 0;
    _testFuelLiters = 0;
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

  Future<void> runPidTest() async {
    if (busy || pidTestRunning || !connected) return;
    final specs = testablePids;
    if (specs.isEmpty) {
      pidTestMessage = 'Nessun PID principale supportato da interrogare.';
      _update();
      return;
    }

    final connectionToken = _generation;
    final runToken = ++_pidTestRun;
    const duration = Duration(seconds: 30);
    final clock = Stopwatch()..start();
    _pidTestClock = clock;
    _pidTestTicker?.cancel();
    _pidTestTicker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (runToken != _pidTestRun || !pidTestRunning) return;
      pidTestProgress = (clock.elapsedMilliseconds / duration.inMilliseconds)
          .clamp(0, 1);
      _update();
    });
    _pidTestResults
      ..clear()
      ..addEntries(
        specs.map((spec) => MapEntry(spec.code, _PidTestAccumulator(spec))),
      );
    _testSpeedKph = null;
    _testFuelRateLph = null;
    _testDistanceKm = 0;
    _testFuelLiters = 0;
    _lastConsumptionIntegration = DateTime.now();
    _cancelPidTestRequested = false;
    pidTestProgress = 0;
    pidTestRunning = true;
    pidTestMessage = 'Test in corso · 0 / 30 s';
    error = null;
    busy = true;
    _log(
      'Avvio test PID per 30 secondi (${specs.length} parametri supportati)',
    );
    _update();

    try {
      while (clock.elapsed < duration &&
          connectionToken == _generation &&
          connected &&
          runToken == _pidTestRun &&
          !_cancelPidTestRequested) {
        for (final spec in specs) {
          if (clock.elapsed >= duration ||
              connectionToken != _generation ||
              !connected ||
              runToken != _pidTestRun ||
              _cancelPidTestRequested) {
            break;
          }

          try {
            final response = await _request(
              spec.command,
              timeout: const Duration(seconds: 2),
            );
            if (connectionToken != _generation || !connected) break;
            final reply = PidDecoder.replies(
              response,
              spec.code,
            ).where((item) => item.ecu == ecu).firstOrNull;
            final accumulator = _pidTestResults[spec.code]!;
            if (reply == null) {
              accumulator.failedSamples++;
              _log(
                'PID ${spec.hex}: ${PidDecoder.noData(response) ? 'nessun dato disponibile' : 'risposta non valida'}',
              );
            } else {
              final value = PidDecoder.decodeStandard(spec.code, reply.bytes);
              final observedAt = DateTime.now();
              _integrateConsumptionUntil(observedAt);
              accumulator.add(value);
              if (spec.code == Pid.speed.code) _testSpeedKph = value;
              if (spec.code == Pid.fuelRate.code) _testFuelRateLph = value;
              _log(
                'PID ${spec.hex} ${spec.label}: ${value.toStringAsFixed(2)} ${spec.unit}',
              );
            }
          } on TimeoutException catch (e) {
            _pidTestResults[spec.code]?.failedSamples++;
            _log('Timeout PID ${spec.hex}: ${readableError(e)}');
            throw ObdException(
              'Timeout durante la lettura del PID ${spec.hex}. Il canale seriale va riconnesso.',
            );
          } on FormatException catch (e) {
            _pidTestResults[spec.code]?.failedSamples++;
            _log('Risposta PID ${spec.hex} non decodificabile: $e');
          }
          _update();
        }
      }

      if (connectionToken == _generation && connected) {
        _integrateConsumptionUntil(DateTime.now());
        pidTestProgress = _cancelPidTestRequested ? pidTestProgress : 1;
        final validCount = _pidTestResults.values.fold<int>(
          0,
          (sum, result) => sum + result.validSamples,
        );
        pidTestMessage = _cancelPidTestRequested
            ? 'Test interrotto dopo ${pidTestElapsedSeconds}s · $validCount letture valide'
            : 'Test completato · 30 s · $validCount letture valide';
        _log(pidTestMessage!);
        if (averageConsumptionLPer100Km != null) {
          _log(
            'Consumo medio stimato nel test: ${averageConsumptionLPer100Km!.toStringAsFixed(2)} l/100 km (${_testDistanceKm.toStringAsFixed(3)} km, ${_testFuelLiters.toStringAsFixed(4)} l)',
          );
        } else {
          _log(
            'Consumo medio in l/100 km non calcolabile: distanza rilevata inferiore a 5 m.',
          );
        }
      }
    } catch (e) {
      if (connectionToken == _generation) {
        error = readableError(e);
        pidTestMessage = 'Test interrotto: ${readableError(e)}';
        _log(pidTestMessage!);
        await _disconnect(statusAfter: 'Collegamento da ripristinare');
      }
    } finally {
      _pidTestTicker?.cancel();
      _pidTestTicker = null;
      clock.stop();
      if (runToken == _pidTestRun) {
        pidTestRunning = false;
        busy = false;
        _update();
      }
    }
  }

  void cancelPidTest() {
    if (!pidTestRunning || _cancelPidTestRequested) return;
    _cancelPidTestRequested = true;
    pidTestMessage = 'Interruzione richiesta…';
    _log('Interruzione test PID richiesta');
    _update();
  }

  void _integrateConsumptionUntil(DateTime at) {
    final previous = _lastConsumptionIntegration;
    if (previous != null && _testSpeedKph != null && _testFuelRateLph != null) {
      final seconds = at.difference(previous).inMicroseconds / 1000000;
      if (seconds > 0 && seconds <= 4) {
        final hours = seconds / 3600;
        _testDistanceKm += _testSpeedKph! * hours;
        _testFuelLiters += _testFuelRateLph! * hours;
      }
    }
    _lastConsumptionIntegration = at;
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
