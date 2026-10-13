import 'package:drive_map/src/app.dart';
import 'package:drive_map/src/domain/trip.dart';
import 'package:drive_map/src/features/analytics/trip_analyzer.dart';
import 'package:drive_map/src/features/obd/obd_session.dart';
import 'package:drive_map/src/providers.dart';
import 'package:drive_map/src/localization/locale_controller.dart';
import 'package:drive_map/src/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Settings extends SettingsController {
  @override
  Future<ScoreConfig> build() async => const ScoreConfig();
}

class _RecordingDashboard extends DashboardController {
  int suspensions = 0;

  @override
  DashboardState build() => const DashboardState(
    connection: ConnectionInfo(phase: ConnectionPhase.ready),
    deviceName: 'OBDLink MX+',
    tripId: 'active-trip',
    frameCount: 12,
  );

  @override
  Future<void> suspend() async => suspensions++;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final language in ['it', 'en']) {
    for (final scenario in [
      (width: 320.0, textScale: 1.0),
      (width: 390.0, textScale: 1.0),
      (width: 390.0, textScale: 1.6),
      (width: 1440.0, textScale: 1.0),
    ]) {
      testWidgets(
        '$language: four compact destinations fit ${scenario.width}px at text scale ${scenario.textScale}',
        (tester) async {
          SharedPreferences.setMockInitialValues({
            LocaleController.preferenceKey: language,
          });
          final strings = await AppLocalizations.delegate.load(
            Locale(language),
          );
          tester.view.physicalSize = Size(scenario.width, 900);
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue =
              scenario.textScale;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                tripsProvider.overrideWith((ref) async => <Trip>[]),
                settingsProvider.overrideWith(_Settings.new),
              ],
              child: const DriveMapApp(),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('DRIVE MAP'), findsOneWidget);
          expect(find.text('OBDLink MX+'), findsOneWidget);
          expect(tester.takeException(), isNull);
          final home = find.byKey(const ValueKey('navigation-home'));
          expect(tester.getSize(home).height, greaterThanOrEqualTo(48));
          if (scenario.textScale == 1) {
            expect(tester.getSize(home).height, lessThan(64));
          }

          await tester.tap(find.byKey(const ValueKey('navigation-telemetry')));
          await tester.pumpAndSettle();
          expect(find.text(strings.telemetryTitle), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.tap(find.byKey(const ValueKey('navigation-trips')));
          await tester.pumpAndSettle();
          expect(find.text(strings.firstTrip), findsOneWidget);
          expect(tester.takeException(), isNull);

          await tester.tap(find.byKey(const ValueKey('navigation-profile')));
          await tester.pumpAndSettle();
          expect(find.text(strings.profileTitle), findsOneWidget);
          expect(tester.takeException(), isNull);

          final settings = find.byKey(const ValueKey('analysis-settings'));
          await tester.ensureVisible(settings);
          await tester.pumpAndSettle();
          await tester.tap(settings);
          await tester.pumpAndSettle();
          expect(find.text(strings.settingsTitle), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Changing tabs keeps the active trip and does not suspend OBD', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardProvider.overrideWith(_RecordingDashboard.new),
          tripsProvider.overrideWith((ref) async => <Trip>[]),
          settingsProvider.overrideWith(_Settings.new),
        ],
        child: const DriveMapApp(),
      ),
    );
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(DriveMapShell)),
    );
    for (final tab in ['telemetry', 'trips', 'profile', 'home']) {
      await tester.tap(find.byKey(ValueKey('navigation-$tab')));
      await tester.pumpAndSettle();
      expect(container.read(dashboardProvider).tripId, 'active-trip');
      expect(container.read(dashboardProvider).recording, isTrue);
      expect(tester.takeException(), isNull);
    }
    expect(
      (container.read(
        dashboardProvider.notifier,
      ) as _RecordingDashboard).suspensions,
      0,
    );
    expect(find.text('Registrazione attiva'), findsOneWidget);
  });
}
