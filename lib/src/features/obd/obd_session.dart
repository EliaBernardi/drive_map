import 'dart:async';

import '../../domain/telemetry.dart';
import 'elm_protocol.dart';
import 'obd_transport.dart';

enum ConnectionPhase {
  disconnected,
  connecting,
  initializing,
  discovering,
  ready,
  reconnecting,
  failed,
}

class ConnectionInfo {
  const ConnectionInfo({
    this.phase = ConnectionPhase.disconnected,
    this.message = 'Collega la tua auto',
    this.supported = const {},
    this.protocol = '',
    this.ecu = '',
    this.reconnects = 0,
    this.responsesPerSecond = 0,
    this.latencyMs = 0,
    this.invalidCount = 0,
  });
  final ConnectionPhase phase;
  final String message;
  final Set<Pid> supported;
  final String protocol;
  final String ecu;
  final int reconnects;
  final double responsesPerSecond;
  final int latencyMs;
  final int invalidCount;
  bool get ready => phase == ConnectionPhase.ready;
}

class ObdSession {
  ObdSession(this.transport);
  final ObdTransport transport;
  final _states = StreamController<ConnectionInfo>.broadcast();
  final _samples = StreamController<RawSample>.broadcast();
  final _frames = StreamController<TelemetryFrame>.broadcast();
  final _assembler = FrameAssembler();
  final _clock = Stopwatch();
  DateTime _epoch = DateTime.now().toUtc();
  ElmChannel? _channel;
  Timer? _frameTimer;
  int _generation = 0;
  int _reconnects = 0;
  int _validResponses = 0;
  int _invalidCount = 0;
  int _lastRateAt = 0;
  int _lastValid = 0;
  int _lastStateAt = 0;
  double _rate = 0;
  int _latency = 0;
  Set<Pid> _supported = {};
  String _ecu = '';
  String _protocol = '';
  bool _disposed = false;
  Future<void>? _run;
  Stream<ConnectionInfo> get states => _states.stream;
  Stream<RawSample> get samples => _samples.stream;
  Stream<TelemetryFrame> get frames => _frames.stream;
  DateTime get now => _epoch.add(_clock.elapsed);

  void _state(ConnectionPhase phase, String message) {
    if (!_disposed) {
      _states.add(
        ConnectionInfo(
          phase: phase,
          message: message,
          supported: Set.unmodifiable(_supported),
          protocol: _protocol,
          ecu: _ecu,
          reconnects: _reconnects,
          responsesPerSecond: _rate,
          latencyMs: _latency,
          invalidCount: _invalidCount,
        ),
      );
    }
  }

  Future<void> connect(String id) async {
    await disconnect();
    final generation = ++_generation;
    _epoch = DateTime.now().toUtc();
    _clock
      ..reset()
      ..start();
    _reconnects = 0;
    _validResponses = _invalidCount = _lastRateAt = _lastValid = _lastStateAt =
        0;
    _rate = 0;
    _run = _maintain(id, generation);
    // _maintain handles errors and publishes state; it runs until disconnect.
  }

  Future<void> _maintain(String id, int generation) async {
    var failures = 0;
    while (generation == _generation && !_disposed) {
      var readyAt = 0;
      try {
        _supported = {};
        _state(
          failures == 0
              ? ConnectionPhase.connecting
              : ConnectionPhase.reconnecting,
          failures == 0
              ? 'Connessione Bluetooth…'
              : 'Riconnessione $failures di 3…',
        );
        _channel = ElmChannel(transport);
        await transport.connect(id).timeout(const Duration(seconds: 20));
        if (generation != _generation) break;
        await _initialize(_channel!);
        if (generation != _generation) break;
        _state(ConnectionPhase.ready, 'Telemetria attiva');
        readyAt = _clock.elapsedMilliseconds;
        _frameTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
          if (generation == _generation && !_disposed) {
            _frames.add(_assembler.frame(now));
          }
        });
        await _poll(_channel!, generation);
      } catch (error) {
        if (generation != _generation || _disposed) break;
        if (readyAt > 0 && _clock.elapsedMilliseconds - readyAt > 30000) {
          failures = 0;
        }
        failures++;
        _state(ConnectionPhase.reconnecting, readableError(error));
      } finally {
        _frameTimer?.cancel();
        _assembler.clear();
        await _channel?.close();
        _channel = null;
        try {
          await transport.disconnect();
        } catch (_) {
          /* Already closed. */
        }
      }
      if (generation != _generation || _disposed) break;
      if (failures > 3) {
        _state(
          ConnectionPhase.failed,
          'Connessione non riuscita. Controlla quadro acceso, Bluetooth e che OBDLink sia chiusa, poi riprova.',
        );
        break;
      }
      _reconnects++;
      // Short waits allow manual cancellation without waiting for the backoff.
      for (
        var i = 0;
        i < (1 << (failures - 1)) * 10 && generation == _generation;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  Future<void> _initialize(ElmChannel channel) async {
    _state(ConnectionPhase.initializing, 'Inizializzazione OBDLink…');
    final reset = await channel.request(
      'ATZ',
      timeout: const Duration(seconds: 6),
    );
    if (!reset.toUpperCase().contains('ELM') &&
        !reset.toUpperCase().contains('STN') &&
        !reset.toUpperCase().contains('OBDLINK')) {
      throw const ObdException('L’adattatore non risponde come ELM/STN.');
    }
    for (final command in [
      'ATE0',
      'ATL0',
      'ATS1',
      'ATH1',
      'ATSP0',
      'ATAT1',
      'ATST64',
    ]) {
      final response = await channel.request(command);
      if (!response.contains('OK')) {
        throw ObdException('Inizializzazione fallita: $command.');
      }
    }
    _state(
      ConnectionPhase.discovering,
      'Verifica centralina e PID supportati…',
    );
    final first = PidDecoder.replies(
      await channel.request('0100', timeout: const Duration(seconds: 15)),
      0,
    );
    if (first.isEmpty) {
      throw const ObdException(
        'La centralina non risponde. Accendi il quadro.',
      );
    }
    final primary = first.firstWhere(
      (r) => r.ecu == '7E8' || r.ecu == '18DAF110',
      orElse: () => first.first,
    );
    _ecu = primary.ecu;
    final codes = PidDecoder.supported(primary.bytes, 0);
    for (var base = 0x20; base <= 0x40 && codes.contains(base); base += 0x20) {
      final response = await channel.request(
        '01${base.toRadixString(16).padLeft(2, '0').toUpperCase()}',
      );
      final replies = PidDecoder.replies(
        response,
        base,
      ).where((r) => r.ecu == _ecu);
      if (replies.isEmpty) break;
      codes.addAll(PidDecoder.supported(replies.first.bytes, base));
    }
    _supported = Pid.values.where((p) => codes.contains(p.code)).toSet();
    if (_supported.isEmpty) {
      throw const ObdException('Nessuno dei PID previsti è disponibile.');
    }
    _protocol = (await channel.request('ATDP')).trim();
  }

  Future<void> _poll(ElmChannel channel, int generation) async {
    final due = {for (final p in _supported) p: 0};
    var consecutiveErrors = 0;
    while (generation == _generation && !_disposed) {
      final pid = due.keys.reduce((a, b) => due[a]! <= due[b]! ? a : b);
      final wait = due[pid]! - _clock.elapsedMilliseconds;
      if (wait > 0) {
        await Future<void>.delayed(Duration(milliseconds: wait.clamp(1, 50)));
        continue;
      }
      final start = _clock.elapsedMilliseconds;
      String response = '';
      double? value;
      SampleQuality quality;
      try {
        response = await channel.request(pid.command);
        final replies = PidDecoder.replies(
          response,
          pid.code,
        ).where((r) => r.ecu == _ecu);
        if (replies.isNotEmpty) {
          value = PidDecoder.decode(pid, replies.first.bytes);
          quality = SampleQuality.valid;
        } else {
          quality = PidDecoder.noData(response)
              ? SampleQuality.noData
              : SampleQuality.invalid;
        }
      } on TimeoutException {
        if (generation == _generation) {
          _samples.add(
            RawSample(
              at: now,
              pid: pid,
              response: response,
              latencyMs: _clock.elapsedMilliseconds - start,
              quality: SampleQuality.timeout,
            ),
          );
        }
        rethrow;
      } on FormatException {
        quality = SampleQuality.invalid;
      }
      if (generation != _generation) break;
      _latency = _clock.elapsedMilliseconds - start;
      final sample = RawSample(
        at: now,
        pid: pid,
        value: value,
        response: response,
        latencyMs: _latency,
        quality: quality,
      );
      _assembler.add(sample);
      _samples.add(sample);
      if (quality == SampleQuality.valid) {
        _validResponses++;
        consecutiveErrors = 0;
      } else {
        _invalidCount++;
        consecutiveErrors++;
      }
      if (consecutiveErrors >= _supported.length * 3) {
        throw const ObdException('La centralina non fornisce più dati.');
      }
      // Back off unsupported-at-runtime PIDs, without removing capability evidence.
      due[pid] =
          _clock.elapsedMilliseconds +
          (quality == SampleQuality.valid ? pid.intervalMs : 5000);
      final elapsed = _clock.elapsedMilliseconds;
      if (elapsed - _lastRateAt >= 2000) {
        _rate = (_validResponses - _lastValid) * 1000 / (elapsed - _lastRateAt);
        _lastValid = _validResponses;
        _lastRateAt = elapsed;
      }
      if (elapsed - _lastStateAt >= 1000) {
        _state(ConnectionPhase.ready, 'Telemetria attiva');
        _lastStateAt = elapsed;
      }
    }
  }

  Future<void> disconnect() async {
    _generation++;
    _frameTimer?.cancel();
    await _channel?.close();
    try {
      await transport.disconnect();
    } catch (_) {
      /* May never have connected. */
    }
    await _run;
    _run = null;
    _assembler.clear();
    _supported = {};
    _clock.stop();
    _state(ConnectionPhase.disconnected, 'Collega la tua auto');
  }

  Future<void> dispose() async {
    _disposed = true;
    await disconnect();
    await _states.close();
    await _samples.close();
    await _frames.close();
  }
}
