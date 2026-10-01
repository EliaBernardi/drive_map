import 'package:drive_map/src/app.dart';
import 'package:drive_map/src/domain/trip.dart';
import 'package:drive_map/src/features/analytics/trip_analyzer.dart';
import 'package:drive_map/src/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Settings extends SettingsController {
  @override
  Future<ScoreConfig> build() async => const ScoreConfig();
}

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets('App shows disconnected state and navigation at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
      expect(find.text('DriveMap'), findsOneWidget);
      expect(find.text('OBDLink MX+'), findsOneWidget);
      expect(find.text('Offline'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(width < 1000 ? 'Viaggi' : 'I miei viaggi'));
      await tester.pumpAndSettle();
      expect(find.text('Il primo viaggio ti aspetta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
