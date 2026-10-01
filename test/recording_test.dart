import 'dart:async';
import 'package:drift/native.dart';
import 'package:drive_map/src/features/analytics/trip_analyzer.dart';
import 'package:drive_map/src/infrastructure/trip_database.dart';
import 'package:drive_map/src/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Settings extends SettingsController {
  @override Future<ScoreConfig> build() async => const ScoreConfig();
}
void main() {
  test('Riverpod demo records, pauses, resumes and persists a reproducible trip', () async {
    final db = TripDatabase(NativeDatabase.memory());
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWith((ref) async => db),
      settingsProvider.overrideWith(_Settings.new),
    ]);
    final controller = container.read(dashboardProvider.notifier);
    addTearDown(() async { await controller.disconnect(); container.dispose(); await db.close(); });
    await controller.connect(demo: true);
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!container.read(dashboardProvider).connection.ready) {
      if (DateTime.now().isAfter(deadline)) fail('Demo did not connect');
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    await controller.start();
    final id = container.read(dashboardProvider).tripId!;
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    await controller.pause();
    final count = container.read(dashboardProvider).frameCount;
    expect(count, greaterThanOrEqualTo(2));
    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(container.read(dashboardProvider).frameCount, count);
    await controller.resume();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    await controller.stop();
    final data = await db.detail(id);
    expect(data.trip.status, 'completed');
    expect(data.trip.source.name, 'demo');
    expect(data.frames.map((f) => f.segment).toSet().length, 2);
    expect(data.frames.length, container.read(dashboardProvider).frameCount);
    expect(container.read(dashboardProvider).tripId, isNull);
    expect(await db.rawSamples(id), isNotEmpty);
    expect(data.trip.configJson, const ScoreConfig().encode());
  });
}
