import 'dart:convert';
import 'dart:io';

import 'package:drive_map/src/app.dart';
import 'package:drive_map/src/domain/telemetry.dart';
import 'package:drive_map/src/domain/trip.dart';
import 'package:drive_map/src/features/analytics/trip_analyzer.dart';
import 'package:drive_map/src/features/obd/obd_session.dart';
import 'package:drive_map/src/localization/locale_controller.dart';
import 'package:drive_map/src/localization/localization.dart';
import 'package:drive_map/src/presentation/adapter_check_screen.dart';
import 'package:drive_map/src/presentation/profile_screen.dart';
import 'package:drive_map/src/presentation/trips_screen.dart';
import 'package:drive_map/src/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ActiveDashboard extends DashboardController {
  int suspensions = 0;

  @override
  DashboardState build() => const DashboardState(
    connection: ConnectionInfo(
      phase: ConnectionPhase.ready,
      message: 'Telemetria attiva',
    ),
    deviceName: 'OBDLink MX+',
    tripId: 'active-trip',
    frameCount: 12,
  );

  @override
  Future<void> suspend() async => suspensions++;
}

class _FailingLocale extends LocaleController {
  @override
  Future<Locale> build() async => const Locale('it');

  @override
  Future<void> select(String languageCode) async =>
      throw StateError('storage unavailable');
}

Future<void> _chooseLanguage(WidgetTester tester, String language) async {
  final picker = find.byType(DropdownButtonFormField<String>);
  await tester.ensureVisible(picker);
  await tester.tap(picker);
  await tester.pumpAndSettle();
  await tester.tap(find.text(language).last);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('The two translation catalogs have matching keys and placeholders', () {
    Map<String, dynamic> catalog(String locale) =>
        jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
            as Map<String, dynamic>;
    final it = catalog('it');
    final en = catalog('en');
    final keys = it.keys.where((key) => !key.startsWith('@')).toSet();
    expect(en.keys.where((key) => !key.startsWith('@')).toSet(), keys);
    for (final key in keys) {
      expect(it[key], isNotEmpty, reason: key);
      expect(en[key], isNotEmpty, reason: key);
      Set<String> placeholders(String text) =>
          RegExp(r'\{(\w+)\}').allMatches(text).map((m) => m[1]!).toSet();
      expect(
        placeholders(en[key] as String),
        placeholders(it[key] as String),
        reason: key,
      );
    }
  });

  test(
    'Italian default, persisted selection and unsupported-language fallback',
    () async {
      final first = ProviderContainer();
      addTearDown(first.dispose);
      expect(await first.read(localeProvider.future), const Locale('it'));
      await first.read(localeProvider.notifier).select('en');
      expect(first.read(localeProvider).asData?.value, const Locale('en'));
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(LocaleController.preferenceKey), 'en');

      final restored = ProviderContainer();
      addTearDown(restored.dispose);
      expect(await restored.read(localeProvider.future), const Locale('en'));
      await restored.read(localeProvider.notifier).select('it');
      expect(preferences.getString(LocaleController.preferenceKey), 'it');
      await expectLater(
        restored.read(localeProvider.notifier).select('fr'),
        throwsArgumentError,
      );

      SharedPreferences.setMockInitialValues({
        LocaleController.preferenceKey: 'fr',
      });
      final fallback = ProviderContainer();
      addTearDown(fallback.dispose);
      expect(await fallback.read(localeProvider.future), const Locale('it'));
    },
  );

  testWidgets(
    'Language changes immediately without replacing OBD, the active trip or the tab',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardProvider.overrideWith(_ActiveDashboard.new),
            tripsProvider.overrideWith((ref) async => <Trip>[]),
          ],
          child: const DriveMapApp(),
        ),
      );
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(DriveMapShell)),
      );
      final dashboard =
          container.read(dashboardProvider.notifier) as _ActiveDashboard;
      final originalState = container.read(dashboardProvider);
      await tester.tap(find.byKey(const ValueKey('navigation-profile')));
      await tester.pumpAndSettle();
      await _chooseLanguage(tester, 'English');
      expect(find.text('Your vehicle.'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Trips'), findsOneWidget);
      expect(
        Localizations.localeOf(tester.element(find.byType(ProfileScreen))),
        const Locale('en'),
      );
      expect(
        identical(container.read(dashboardProvider), originalState),
        isTrue,
      );
      expect(
        identical(container.read(dashboardProvider.notifier), dashboard),
        isTrue,
      );
      expect(container.read(dashboardProvider).recording, isTrue);
      expect(dashboard.suspensions, 0);

      await tester.tap(find.byKey(const ValueKey('navigation-home')));
      await tester.pumpAndSettle();
      expect(find.text('Ready to go?'), findsOneWidget);
      expect(find.text('Telemetry active'), findsOneWidget);
      expect(find.text('Recording active'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('navigation-profile')));
      await tester.pumpAndSettle();
      await _chooseLanguage(tester, 'Italiano');
      expect(find.text('Il tuo veicolo.'), findsOneWidget);
      expect(container.read(dashboardProvider).tripId, 'active-trip');
      expect(dashboard.suspensions, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Failed language save restores the selection and reports an error',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localeProvider.overrideWith(_FailingLocale.new),
            tripsProvider.overrideWith((ref) async => <Trip>[]),
          ],
          child: const DriveMapApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('navigation-profile')));
      await tester.pumpAndSettle();
      await _chooseLanguage(tester, 'English');
      expect(find.text('Il tuo veicolo.'), findsOneWidget);
      expect(
        find.text('Impossibile salvare la lingua. Riprova.'),
        findsOneWidget,
      );
      final picker = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      expect(picker.initialValue, 'it');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Saved English locale reaches diagnostics and trip analysis routes',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        LocaleController.preferenceKey: 'en',
      });
      final frames = List.generate(
        12,
        (i) => TelemetryFrame(
          at: DateTime.utc(2026, 10, 13).add(Duration(seconds: i)),
          values: {Pid.rpm: 1800, Pid.load: 30, Pid.speed: 40, Pid.coolant: 60},
        ),
      );
      final analysis = TripAnalyzer.analyze(frames, const ScoreConfig());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripsProvider.overrideWith((ref) async => <Trip>[]),
            analysisProvider('example').overrideWith((ref) async => analysis),
            tripDetailProvider('example').overrideWith(
              (ref) async => TripData(
                Trip(
                  id: 'example',
                  name: 'Example',
                  startedAt: frames.first.at,
                  source: TripSource.obd,
                  status: 'completed',
                  configJson: const ScoreConfig().encode(),
                ),
                frames,
              ),
            ),
          ],
          child: const DriveMapApp(),
        ),
      );
      await tester.pumpAndSettle();
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const AdapterCheckScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Connect your OBDLink'), findsOneWidget);
      expect(find.text('Status: Disconnected'), findsOneWidget);
      navigator.pop();
      await tester.pumpAndSettle();
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const TripAnalysisScreen(id: 'example'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('YOUR SCORE'), findsOneWidget);
      expect(find.text('Operating zones'), findsOneWidget);
      expect(
        find.textContaining('Score 100/100 across 3 available components.'),
        findsOneWidget,
      );
      final map = find.text('Your engine map');
      await tester.ensureVisible(map);
      await tester.pumpAndSettle();
      expect(map, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('Localized messages retain ECU/PID identifiers and unknown hardware responses', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final it = await AppLocalizations.delegate.load(const Locale('it'));
    expect(
      en.message('47 PID standard rilevati sulla centralina 7E8.'),
      '47 standard PIDs detected on ECU 7E8.',
    );
    expect(
      en.message('Connessione a OBDLink MX+ 15288…'),
      'Connecting to OBDLink MX+ 15288…',
    );
    expect(en.message('Riconnessione 2 di 3…'), 'Reconnection 2 of 3…');
    expect(
      en.message(
        'Penalità per carico oltre 50% sotto 70 °C, sul tempo osservato.',
      ),
      'Penalty for load over 50% below 70 °C, over observed time.',
    );
    expect(en.message('Frenata brusca'), 'Hard braking');
    expect(en.pidLabel(0xA6), 'Total odometer');
    expect(it.pidLabel(0xA6), 'Contachilometri totale');
    expect(en.message('7E8 06 41 00 BE 3E A8 13'), '7E8 06 41 00 BE 3E A8 13');
    expect(
      en.error(const FormatException('Seleziona la colonna del tempo.')),
      'Select the time column.',
    );
  });
}
