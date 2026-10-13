import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'theme/app_theme.dart';
import 'presentation/telemetry_screen.dart';
import 'presentation/home_screen.dart';
import 'presentation/main_scaffold.dart';
import 'presentation/profile_screen.dart';
import 'presentation/trips_screen.dart';

class DriveMapApp extends StatelessWidget {
  const DriveMapApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DRIVE MAP',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const DriveMapShell(),
  );
}

class DriveMapShell extends ConsumerStatefulWidget {
  const DriveMapShell({super.key});
  @override
  ConsumerState<DriveMapShell> createState() => _DriveMapShellState();
}

class _DriveMapShellState extends ConsumerState<DriveMapShell>
    with WidgetsBindingObserver {
  MainDestination _destination = MainDestination.home;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      unawaited(ref.read(dashboardProvider.notifier).suspend());
    }
  }

  void _select(MainDestination destination) {
    if (destination != _destination) setState(() => _destination = destination);
  }

  @override
  Widget build(BuildContext context) {
    final connection = ref.watch(
      dashboardProvider.select(
        (s) => (ready: s.connection.ready, demo: s.demo),
      ),
    );
    return MainScaffold(
      destination: _destination,
      onDestinationSelected: _select,
      connectionLabel: connection.ready
          ? connection.demo
                ? 'Demo'
                : 'OBD connesso'
          : 'Offline',
      connectionColor: connection.ready
          ? connection.demo
                ? DriveColors.amber
                : DriveColors.accent
          : DriveColors.muted,
      body: IndexedStack(
        index: _destination.index,
        children: [
          HomeScreen(
            onTelemetry: () => _select(MainDestination.telemetry),
            onTrips: () => _select(MainDestination.trips),
          ),
          TelemetryScreen(onHome: () => _select(MainDestination.home)),
          const TripsScreen(),
          const ProfileScreen(),
        ],
      ),
    );
  }
}
