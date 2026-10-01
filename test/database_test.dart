import 'package:drift/native.dart';
import 'package:drive_map/src/domain/telemetry.dart';
import 'package:drive_map/src/domain/trip.dart';
import 'package:drive_map/src/features/analytics/trip_analyzer.dart';
import 'package:drive_map/src/infrastructure/trip_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Atomic recording, crash recovery, raw log and cascade deletion',
    () async {
      final db = TripDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final at = DateTime.utc(2026);
      await db.createTrip(
        Trip(
          id: '1',
          name: 'Test',
          startedAt: at,
          source: TripSource.obd,
          status: 'recording',
          configJson: const ScoreConfig().encode(),
        ),
        {Pid.rpm},
      );
      final frame = TelemetryFrame(at: at, values: {Pid.rpm: 1200});
      await db.append(
        '1',
        [frame, frame],
        [
          RawSample(
            at: at,
            pid: Pid.rpm,
            value: 1200,
            response: '7E8 04 41 0C 12 C0',
            latencyMs: 30,
            quality: SampleQuality.valid,
          ),
        ],
      );
      expect((await db.detail('1')).frames.length, 1);
      expect((await db.rawSamples('1')).single['quality'], 'valid');
      await db.recoverInterrupted();
      expect((await db.trips()).single.status, 'interrupted');
      expect((await db.trips()).single.frameCount, 1);
      await db.deleteTrip('1');
      expect(await db.trips(), isEmpty);
      expect(await db.rawSamples('1'), isEmpty);
    },
  );
}
