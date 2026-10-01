import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'domain/telemetry.dart';
import 'domain/trip.dart';
import 'features/analytics/trip_analyzer.dart';
import 'features/obd/demo_transport.dart';
import 'features/obd/obd_session.dart';
import 'features/obd/obd_transport.dart';
import 'infrastructure/trip_database.dart';

final databaseProvider = FutureProvider<TripDatabase>((ref) async {
  final db = await TripDatabase.open();
  if (!ref.mounted) {
    await db.close();
    throw StateError('Database disposed');
  }
  ref.onDispose(() => unawaited(db.close()));
  return db;
});
final tripsProvider = FutureProvider<List<Trip>>(
  (ref) async => (await ref.watch(databaseProvider.future)).trips(),
);
final tripDetailProvider = FutureProvider.family<TripData, String>(
  (ref, id) async => (await ref.watch(databaseProvider.future)).detail(id),
);
final analysisProvider = FutureProvider.family<TripAnalysis, String>((
  ref,
  id,
) async {
  final data = await ref.watch(tripDetailProvider(id).future);
  return TripAnalyzer.analyze(
    data.frames,
    ScoreConfig.decode(data.trip.configJson),
  );
});

final settingsProvider = AsyncNotifierProvider<SettingsController, ScoreConfig>(
  SettingsController.new,
);

class SettingsController extends AsyncNotifier<ScoreConfig> {
  @override
  Future<ScoreConfig> build() async {
    final value = (await SharedPreferences.getInstance()).getString(
      'score_config',
    );
    return value == null ? const ScoreConfig() : ScoreConfig.decode(value);
  }

  Future<void> save(ScoreConfig config) async {
    config.validate();
    final saved = await (await SharedPreferences.getInstance()).setString(
      'score_config',
      config.encode(),
    );
    if (!saved) throw StateError('Impossibile salvare le impostazioni.');
    if (ref.mounted) state = AsyncData(config);
  }
}

class DashboardState {
  const DashboardState({
    this.connection = const ConnectionInfo(),
    this.frame,
    this.devices = const [],
    this.demo = false,
    this.deviceName = '',
    this.loadingDevices = false,
    this.busy = false,
    this.tripId,
    this.paused = false,
    this.frameCount = 0,
    this.error,
    this.savedTripId,
  });
  final ConnectionInfo connection;
  final TelemetryFrame? frame;
  final List<ObdDevice> devices;
  final bool demo, loadingDevices, busy, paused;
  final String deviceName;
  final String? tripId, error, savedTripId;
  final int frameCount;
  bool get recording => tripId != null && !paused;
  bool get hasTrip => tripId != null;
  DashboardState copy({
    ConnectionInfo? connection,
    TelemetryFrame? frame,
    List<ObdDevice>? devices,
    bool? demo,
    String? deviceName,
    bool? loadingDevices,
    bool? busy,
    String? tripId,
    bool? paused,
    int? frameCount,
    String? error,
    String? savedTripId,
    bool clearFrame = false,
    bool clearTrip = false,
    bool clearError = false,
  }) => DashboardState(
    connection: connection ?? this.connection,
    frame: clearFrame ? null : frame ?? this.frame,
    devices: devices ?? this.devices,
    demo: demo ?? this.demo,
    deviceName: deviceName ?? this.deviceName,
    loadingDevices: loadingDevices ?? this.loadingDevices,
    busy: busy ?? this.busy,
    tripId: clearTrip ? null : tripId ?? this.tripId,
    paused: paused ?? this.paused,
    frameCount: frameCount ?? this.frameCount,
    error: clearError ? null : error ?? this.error,
    savedTripId: savedTripId ?? this.savedTripId,
  );
}

final dashboardProvider = NotifierProvider<DashboardController, DashboardState>(
  DashboardController.new,
);

class DashboardController extends Notifier<DashboardState> {
  ObdSession? _session;
  DemoTransport? _demoTransport;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final List<TelemetryFrame> _pendingFrames = [];
  final List<RawSample> _pendingSamples = [];
  Future<void>? _flushing;
  Timer? _flushTimer;
  int _segment = 0;
  bool _wasReady = false;
  bool _suspending = false;
  TripDatabase? _database;
  @override
  DashboardState build() {
    ref.onDispose(() {
      _flushTimer?.cancel();
      for (final sub in _subscriptions) {
        unawaited(sub.cancel());
      }
      unawaited(_session?.dispose());
      unawaited(_demoTransport?.dispose());
    });
    return const DashboardState();
  }

  void dismissError() => state = state.copy(clearError: true);
  void _error(Object error) {
    if (ref.mounted) {
      state = state.copy(error: readableError(error), busy: false);
    }
  }

  Future<void> discover() async {
    if (state.loadingDevices) return;
    state = state.copy(loadingDevices: true, clearError: true);
    try {
      final devices = await PlatformObdTransport.devices();
      if (ref.mounted) state = state.copy(devices: devices);
    } catch (error) {
      _error(error);
    } finally {
      if (ref.mounted) state = state.copy(loadingDevices: false);
    }
  }

  Future<void> pairing() async {
    try {
      await PlatformObdTransport.pairing();
    } catch (error) {
      _error(error);
    }
  }

  Future<void> connect({ObdDevice? device, bool demo = false}) async {
    if (state.busy || state.recording || (state.hasTrip && state.demo != demo)) {
      return;
    }
    state = state.copy(busy: true, clearError: true, clearFrame: true);
    try {
      await _disposeSession();
      final ObdTransport transport;
      if (demo) {
        _demoTransport = DemoTransport();
        transport = _demoTransport!;
      } else {
        transport = PlatformObdTransport();
      }
      final session = ObdSession(transport);
      _session = session;
      state = state.copy(
        demo: demo,
        deviceName: demo ? 'Simulatore OBD' : device!.name,
      );
      _subscriptions.add(
        session.states.listen((connection) {
          if (!ref.mounted) return;
          if (_wasReady && !connection.ready) _segment++;
          _wasReady = connection.ready;
          state = state.copy(
            connection: connection,
            clearFrame: !connection.ready,
          );
        }),
      );
      _subscriptions.add(
        session.frames.listen((frame) {
          if (!ref.mounted) return;
          state = state.copy(frame: frame);
          if (state.recording) {
            _pendingFrames.add(frame.inSegment(_segment));
            state = state.copy(frameCount: state.frameCount + 1);
          }
        }),
      );
      _subscriptions.add(
        session.samples.listen((sample) {
          if (ref.mounted && state.recording) _pendingSamples.add(sample);
        }),
      );
      await session.connect(demo ? 'demo' : device!.id);
    } catch (error) {
      _error(error);
    } finally {
      if (ref.mounted) state = state.copy(busy: false);
    }
  }

  Future<void> _disposeSession() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    await _session?.dispose();
    _session = null;
    await _demoTransport?.dispose();
    _demoTransport = null;
    _wasReady = false;
  }

  Future<void> disconnect() async {
    if (state.busy) return;
    if (state.recording) await pause();
    await _disposeSession();
    if (ref.mounted) {
      state = state.copy(connection: const ConnectionInfo(), clearFrame: true);
    }
  }

  Future<void> start() async {
    if (state.busy || !state.connection.ready || state.hasTrip) return;
    state = state.copy(busy: true, clearError: true);
    try {
      _database = await ref.read(databaseProvider.future);
      final config = await ref.read(settingsProvider.future);
      final now = DateTime.now().toUtc();
      final id = now.microsecondsSinceEpoch.toString();
      await _database!.createTrip(
        Trip(
          id: id,
          name: state.demo
              ? 'Viaggio dimostrativo'
              : 'Viaggio ${now.toLocal().day}/${now.toLocal().month}',
          startedAt: now,
          source: state.demo ? TripSource.demo : TripSource.obd,
          status: 'recording',
          configJson: config.encode(),
        ),
        state.connection.supported,
      );
      if (!ref.mounted) return;
      _segment = 0;
      state = state.copy(tripId: id, paused: false, frameCount: 0);
      _flushTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => unawaited(_autoFlush()),
      );
      ref.invalidate(tripsProvider);
    } catch (error) {
      _error(error);
    } finally {
      if (ref.mounted) state = state.copy(busy: false);
    }
  }

  Future<void> _autoFlush() async {
    try {
      await _flush();
    } catch (error) {
      if (ref.mounted) {
        state = state.copy(
          paused: true,
          error:
              'Salvataggio non riuscito; registrazione in pausa. I dati in memoria sono conservati. ${readableError(error)}',
        );
      }
      _flushTimer?.cancel();
    }
  }

  Future<void> _flush() async {
    if (_flushing != null) {
      await _flushing;
      return;
    }
    if (state.tripId == null ||
        (_pendingFrames.isEmpty && _pendingSamples.isEmpty)) {
      return;
    }
    final frames = List<TelemetryFrame>.of(_pendingFrames);
    final samples = List<RawSample>.of(_pendingSamples);
    final task = _database!.append(state.tripId!, frames, samples);
    _flushing = task;
    try {
      await task;
      _pendingFrames.removeRange(0, frames.length);
      _pendingSamples.removeRange(0, samples.length);
    } finally {
      _flushing = null;
    }
  }

  Future<void> pause() async {
    if (!state.hasTrip || state.busy) return;
    state = state.copy(paused: true, busy: true);
    _segment++;
    try {
      await _flush();
      await _flush();
      await _database!.setStatus(state.tripId!, 'paused');
    } catch (error) {
      _error(error);
    } finally {
      if (ref.mounted) state = state.copy(busy: false);
    }
  }

  Future<void> resume() async {
    if (!state.hasTrip || state.busy || !state.connection.ready) return;
    state = state.copy(busy: true, clearError: true);
    try {
      await _flush();
      await _database!.setStatus(state.tripId!, 'recording');
      _segment++;
      _flushTimer?.cancel();
      _flushTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => unawaited(_autoFlush()),
      );
      if (ref.mounted) state = state.copy(paused: false);
    } catch (error) {
      _error(error);
    } finally {
      if (ref.mounted) state = state.copy(busy: false);
    }
  }

  Future<void> stop() async {
    if (!state.hasTrip || state.busy) return;
    final id = state.tripId!;
    state = state.copy(paused: true, busy: true, clearError: true);
    _flushTimer?.cancel();
    try {
      await _flush();
      await _flush();
      final data = await _database!.detail(id);
      final analysis = TripAnalyzer.analyze(
        data.frames,
        ScoreConfig.decode(data.trip.configJson),
      );
      await _database!.transaction(() async {
        await _database!.saveAnalysis(id, analysis);
        await _database!.setStatus(
          id,
          'completed',
          end: data.frames.isEmpty ? data.trip.startedAt : data.frames.last.at,
        );
      });
      if (!ref.mounted) return;
      state = state.copy(clearTrip: true, savedTripId: id, paused: false);
      ref.invalidate(tripsProvider);
      ref.invalidate(tripDetailProvider(id));
      ref.invalidate(analysisProvider(id));
    } catch (error) {
      _error(error);
    } finally {
      if (ref.mounted) state = state.copy(busy: false);
    }
  }

  /// Foreground acquisition is explicit: no promise of background collection.
  Future<void> suspend() async {
    if (_suspending) return;
    _suspending = true;
    try {
      while (ref.mounted && state.busy) {
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }
      if (!ref.mounted) return;
      if (state.recording) await pause();
      await disconnect();
    } finally {
      _suspending = false;
    }
  }
}
