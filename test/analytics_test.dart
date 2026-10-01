import 'package:drive_map/src/domain/telemetry.dart';
import 'package:drive_map/src/features/analytics/trip_analyzer.dart';
import 'package:drive_map/src/features/trips/csv_importer.dart';
import 'package:flutter_test/flutter_test.dart';

List<TelemetryFrame> trip({
  double rpm = 2000,
  double load = 40,
  bool fuel = true,
}) => [
  for (var i = 0; i <= 120; i++)
    TelemetryFrame(
      at: DateTime.utc(2026).add(Duration(milliseconds: i * 500)),
      values: {
        Pid.rpm: rpm,
        Pid.load: load,
        Pid.coolant: 90,
        Pid.speed: 60,
        if (fuel) Pid.fuelRate: 6,
      },
    ),
];
void main() {
  test('Time, fuel units, distance and map agree on constant trip', () {
    final a = TripAnalyzer.analyze(trip(), const ScoreConfig());
    expect(a.duration, 60);
    expect(a.distanceKm, closeTo(1, 1e-9));
    expect(a.fuelLiters, closeTo(.1, 1e-9));
    expect(a.consumption, closeTo(10, 1e-9));
    expect(a.cells.fold(0.0, (s, c) => s + c.seconds), a.validMapSeconds);
    expect(a.score, closeTo(100, 1e-9));
    expect(a.parts.last.value, isNull);
  });
  test('100 percent load lands in top cell; adverse zones lower score', () {
    final good = TripAnalyzer.analyze(trip(), const ScoreConfig());
    final bad = TripAnalyzer.analyze(
      trip(rpm: 4000, load: 100),
      const ScoreConfig(),
    );
    expect(bad.cells.single.loadBin, 9);
    expect(bad.score!, lessThan(good.score!));
    expect(bad.score!, inInclusiveRange(0, 100));
  });
  test('Missing data is unavailable, never zero or perfect score', () {
    final withoutFuel = TripAnalyzer.analyze(
      trip(fuel: false),
      const ScoreConfig(baselineConsumption: 6),
    );
    expect(withoutFuel.fuelLiters, isNull);
    expect(withoutFuel.consumption, isNull);
    expect(withoutFuel.parts.last.value, isNull);
    expect(TripAnalyzer.analyze([], const ScoreConfig()).score, isNull);
  });
  test('Pauses and long gaps are excluded from integrations', () {
    final frames = [
      ...trip().take(11),
      ...trip()
          .take(11)
          .map(
            (f) => TelemetryFrame(
              at: f.at.add(const Duration(minutes: 5)),
              values: f.values,
              segment: 1,
            ),
          ),
    ];
    final a = TripAnalyzer.analyze(frames, const ScoreConfig());
    expect(a.duration, 10);
    expect(a.validMapSeconds, 10);
    expect(a.distanceKm, closeTo(1 / 6, 1e-9));
  });
  test(
    'Duplicate, out of order, NaN and stale frames handled deterministically',
    () {
      final frames = trip();
      final baseline = TripAnalyzer.analyze(frames, const ScoreConfig());
      final shuffled = TripAnalyzer.analyze([
        ...frames.reversed,
        frames.first,
      ], const ScoreConfig());
      expect(shuffled.score, baseline.score);
      expect(shuffled.duplicates, 1);
      final stale = TelemetryFrame(
        at: DateTime.utc(2026, 1, 1, 0, 1),
        values: {Pid.rpm: double.nan, Pid.speed: 60},
        observedAt: {
          Pid.rpm: DateTime.utc(2026),
          Pid.speed: DateTime.utc(2026),
        },
      );
      expect(
        TripAnalyzer.analyze([stale], const ScoreConfig()).frames.single.values,
        isEmpty,
      );
    },
  );
  test('Reused speed samples do not create resampling acceleration spikes', () {
    final frames = [
      for (var i = 0; i <= 20; i++)
        TelemetryFrame(
          at: DateTime.utc(2026).add(Duration(milliseconds: i * 500)),
          values: {Pid.speed: (i ~/ 2) * 3.6, Pid.rpm: 2000, Pid.load: 30},
          observedAt: {
            Pid.speed: DateTime.utc(2026).add(Duration(seconds: i ~/ 2)),
            Pid.rpm: DateTime.utc(2026).add(Duration(milliseconds: i * 500)),
            Pid.load: DateTime.utc(2026).add(Duration(milliseconds: i * 500)),
          },
        ),
    ];
    expect(
      TripAnalyzer.analyze(
        frames,
        const ScoreConfig(hardAcceleration: 1.5),
      ).events,
      isEmpty,
    );
  });
  test('CSV export and import preserve observed timestamps and segments', () {
    final frames = trip();
    final preview = CsvPreview.parse(CsvImporter.export(frames));
    final result = CsvImporter.convert(
      preview,
      preview.guessTime(),
      {
        for (final p in Pid.values)
          if (preview.guess(p) >= 0) p: preview.guess(p),
      },
      elapsedSeconds: false,
      origin: DateTime.utc(2026),
    );
    expect(result.frames.length, frames.length);
    expect(result.frames.first.toJson(), frames.first.toJson());
    expect(TripAnalyzer.analyze(result.frames, const ScoreConfig()).score, closeTo(100, 1e-9));
  });
  test(
    'CSV unknown units and duplicate timestamps are not silently trusted',
    () {
      final preview = CsvPreview.parse('time,fuel rate (g/s)\n0,1\n0,2\n1,2');
      expect(
        () => CsvImporter.convert(
          preview,
          0,
          {Pid.fuelRate: 1},
          elapsedSeconds: true,
          origin: DateTime.utc(2026),
        ),
        throwsFormatException,
      );
      final valid = CsvPreview.parse(
        'time;vehicle speed (mph)\n0;10\n0;11\n1;12',
      );
      final result = CsvImporter.convert(
        valid,
        0,
        {Pid.speed: 1},
        elapsedSeconds: true,
        origin: DateTime.utc(2026),
      );
      expect(result.discardedRows, 1);
      expect(result.frames.first[Pid.speed], closeTo(16.09344, 1e-8));
    },
  );
  test('Score config round-trip is versioned and validates weights', () {
    const config = ScoreConfig(highRpm: 3200);
    expect(ScoreConfig.decode(config.encode()).highRpm, 3200);
    expect(
      () => const ScoreConfig(zoneWeight: -1).validate(),
      throwsFormatException,
    );
  });
}
