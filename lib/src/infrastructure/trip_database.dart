import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/telemetry.dart';
import '../domain/trip.dart';
import '../features/analytics/trip_analyzer.dart';

/// Explicit SQL schema managed by Drift, with all writes on its worker isolate.
/// Keeping the SQL here avoids generated files while retaining transactions,
/// migrations, parameter binding and platform-independent SQLite persistence.
class TripDatabase extends GeneratedDatabase {
  TripDatabase(super.executor);
  static Future<TripDatabase> open() async {
    final directory = await getApplicationSupportDirectory();
    final db = TripDatabase(
      NativeDatabase.createInBackground(
        File(p.join(directory.path, 'drivemap.sqlite')),
      ),
    );
    await db.recoverInterrupted();
    return db;
  }

  @override
  int get schemaVersion => 1;
  @override
  Iterable<TableInfo> get allTables => const [];
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async {
      for (final sql in _schema) {
        await customStatement(sql);
      }
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );

  static const _schema = [
    '''CREATE TABLE trip (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, vehicle TEXT NOT NULL,
      started_at TEXT NOT NULL, ended_at TEXT, source TEXT NOT NULL,
      status TEXT NOT NULL, config_json TEXT NOT NULL)''',
    '''CREATE TABLE telemetry_frame (
      trip_id TEXT NOT NULL REFERENCES trip(id) ON DELETE CASCADE,
      timestamp TEXT NOT NULL, payload TEXT NOT NULL,
      PRIMARY KEY(trip_id, timestamp))''',
    '''CREATE TABLE sample_raw (
      id INTEGER PRIMARY KEY, trip_id TEXT NOT NULL REFERENCES trip(id) ON DELETE CASCADE,
      timestamp TEXT NOT NULL, pid TEXT NOT NULL, value REAL, unit TEXT NOT NULL,
      quality TEXT NOT NULL, latency_ms INTEGER NOT NULL, response TEXT NOT NULL)''',
    'CREATE INDEX raw_trip_time ON sample_raw(trip_id, timestamp)',
    '''CREATE TABLE pid_support (
      trip_id TEXT NOT NULL REFERENCES trip(id) ON DELETE CASCADE,
      pid TEXT NOT NULL, supported INTEGER NOT NULL, PRIMARY KEY(trip_id, pid))''',
    '''CREATE TABLE trip_event (
      trip_id TEXT NOT NULL REFERENCES trip(id) ON DELETE CASCADE,
      timestamp TEXT NOT NULL, type TEXT NOT NULL, value REAL NOT NULL)''',
    '''CREATE TABLE trip_zone_stat (
      trip_id TEXT NOT NULL REFERENCES trip(id) ON DELETE CASCADE,
      rpm_bin INTEGER NOT NULL, load_bin INTEGER NOT NULL, sample_count INTEGER NOT NULL,
      seconds REAL NOT NULL, mean_speed REAL, mean_fuel REAL, penalty REAL NOT NULL,
      PRIMARY KEY(trip_id, rpm_bin, load_bin))''',
  ];

  Future<void> recoverInterrupted() =>
      customStatement('''UPDATE trip SET status = 'interrupted',
    ended_at = COALESCE((SELECT MAX(timestamp) FROM telemetry_frame WHERE trip_id = trip.id), started_at)
    WHERE status IN ('recording', 'paused')''');

  Future<void> createTrip(Trip trip, Set<Pid> supported) =>
      transaction(() async {
        await customStatement(
          'INSERT INTO trip VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          [
            trip.id,
            trip.name,
            trip.vehicle,
            trip.startedAt.toIso8601String(),
            trip.endedAt?.toIso8601String(),
            trip.source.name,
            trip.status,
            trip.configJson,
          ],
        );
        for (final pid in Pid.values) {
          await customStatement('INSERT INTO pid_support VALUES (?, ?, ?)', [
            trip.id,
            pid.hex,
            supported.contains(pid) ? 1 : 0,
          ]);
        }
      });

  Future<void> append(
    String id,
    List<TelemetryFrame> frames,
    List<RawSample> samples,
  ) => transaction(() async {
    for (final frame in frames) {
      await customStatement(
        'INSERT OR IGNORE INTO telemetry_frame VALUES (?, ?, ?)',
        [id, frame.at.toIso8601String(), jsonEncode(frame.toJson())],
      );
    }
    for (final sample in samples) {
      await customStatement(
        'INSERT INTO sample_raw(trip_id,timestamp,pid,value,unit,quality,latency_ms,response) VALUES(?,?,?,?,?,?,?,?)',
        [
          id,
          sample.at.toIso8601String(),
          sample.pid.hex,
          sample.value,
          sample.pid.unit,
          sample.quality.name,
          sample.latencyMs,
          sample.response,
        ],
      );
    }
  });

  Future<void> setStatus(String id, String status, {DateTime? end}) =>
      customStatement('UPDATE trip SET status = ?, ended_at = ? WHERE id = ?', [
        status,
        end?.toIso8601String(),
        id,
      ]);

  Future<void> saveAnalysis(String id, TripAnalysis analysis) =>
      transaction(() async {
        await customStatement('DELETE FROM trip_event WHERE trip_id = ?', [id]);
        await customStatement('DELETE FROM trip_zone_stat WHERE trip_id = ?', [
          id,
        ]);
        for (final event in analysis.events) {
          await customStatement('INSERT INTO trip_event VALUES(?,?,?,?)', [
            id,
            event.at.toIso8601String(),
            event.label,
            event.value,
          ]);
        }
        for (final cell in analysis.cells) {
          await customStatement(
            'INSERT INTO trip_zone_stat VALUES(?,?,?,?,?,?,?,?)',
            [
              id,
              cell.rpmBin,
              cell.loadBin,
              cell.samples,
              cell.seconds,
              cell.meanSpeed,
              cell.meanFuel,
              cell.penalty,
            ],
          );
        }
      });

  Future<List<Trip>> trips() async {
    final rows = await customSelect('''SELECT trip.*, (SELECT COUNT(*) FROM telemetry_frame WHERE trip_id = trip.id) AS frame_count
      FROM trip ORDER BY started_at DESC''').get();
    return rows.map(_trip).toList();
  }

  Trip _trip(QueryRow row) => Trip(
    id: row.read<String>('id'),
    name: row.read<String>('name'),
    vehicle: row.read<String>('vehicle'),
    startedAt: DateTime.parse(row.read<String>('started_at')),
    endedAt: row.readNullable<String>('ended_at') == null
        ? null
        : DateTime.parse(row.read<String>('ended_at')),
    source: TripSource.values.byName(row.read<String>('source')),
    status: row.read<String>('status'),
    configJson: row.read<String>('config_json'),
    frameCount: row.data['frame_count'] as int? ?? 0,
  );

  Future<TripData> detail(String id) async {
    final trip = await customSelect(
      'SELECT * FROM trip WHERE id = ?',
      variables: [Variable(id)],
    ).getSingle();
    final rows = await customSelect(
      'SELECT payload FROM telemetry_frame WHERE trip_id = ? ORDER BY timestamp',
      variables: [Variable(id)],
    ).get();
    return TripData(
      _trip(trip),
      rows
          .map(
            (r) => TelemetryFrame.fromJson(
              jsonDecode(r.read<String>('payload')) as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Future<List<Map<String, Object?>>> rawSamples(String id) async =>
      (await customSelect(
        'SELECT timestamp,pid,value,unit,quality,latency_ms,response FROM sample_raw WHERE trip_id = ? ORDER BY timestamp',
        variables: [Variable(id)],
      ).get()).map((r) => r.data).toList();

  Future<void> deleteTrip(String id) =>
      customStatement('DELETE FROM trip WHERE id = ?', [id]);
}
