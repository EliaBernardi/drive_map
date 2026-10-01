import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'presentation/components.dart';
import 'presentation/dashboard_screen.dart';
import 'presentation/settings_screen.dart';
import 'presentation/trips_screen.dart';

class DriveMapApp extends StatelessWidget {
  const DriveMapApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'DriveMap',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DriveColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: DriveColors.accent,
        brightness: Brightness.dark,
        primary: DriveColors.accent,
        surface: DriveColors.surface,
      ),
      fontFamily: 'Roboto',
      dividerColor: DriveColors.border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DriveColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DriveColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
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
  int _tab = 0;
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

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wide)
              Container(
                width: 222,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: DriveColors.border)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Brand(),
                    const SizedBox(height: 48),
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text(
                        'IL TUO SPAZIO DI GUIDA',
                        style: TextStyle(
                          color: DriveColors.muted,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (var i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          selected: _tab == i,
                          selectedTileColor: DriveColors.accent.withValues(
                            alpha: .10,
                          ),
                          selectedColor: DriveColors.accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: Icon(
                            [
                              Icons.space_dashboard_outlined,
                              Icons.route_outlined,
                              Icons.tune_rounded,
                            ][i],
                          ),
                          title: Text(
                            ['Panoramica', 'I miei viaggi', 'Il modello'][i],
                          ),
                          onTap: () => setState(() => _tab = i),
                        ),
                      ),
                    const Spacer(),
                    const Panel(
                      padding: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.directions_car_outlined,
                            color: DriveColors.accent,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Ford Fiesta',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '2021 · Veicolo di studio',
                            style: TextStyle(
                              color: DriveColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'DriveMap / Progetto OBD-II',
                      style: TextStyle(color: DriveColors.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 36 : 20,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        if (!wide)
                          const _Brand()
                        else
                          Text(
                            [
                              'PANORAMICA',
                              'ARCHIVIO VIAGGI',
                              'MODELLO E PARAMETRI',
                            ][_tab],
                            style: const TextStyle(
                              fontSize: 11,
                              letterSpacing: 2,
                              color: DriveColors.muted,
                            ),
                          ),
                        const Spacer(),
                        Consumer(
                          builder: (context, ref, _) {
                            final data = ref.watch(dashboardProvider);
                            return StatusPill(
                              data.demo && data.connection.ready
                                  ? 'DEMO'
                                  : data.connection.ready
                                  ? 'OBD connesso'
                                  : 'Offline',
                              color: data.demo && data.connection.ready
                                  ? DriveColors.amber
                                  : data.connection.ready
                                  ? DriveColors.accent
                                  : DriveColors.muted,
                              icon: Icons.bluetooth,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: IndexedStack(
                      index: _tab,
                      children: [
                        DashboardScreen(
                          onTrips: () => setState(() => _tab = 1),
                        ),
                        const TripsScreen(),
                        const SettingsScreen(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _tab,
              onDestinationSelected: (value) => setState(() => _tab = value),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.space_dashboard_outlined),
                  selectedIcon: Icon(Icons.space_dashboard),
                  label: 'Live',
                ),
                NavigationDestination(
                  icon: Icon(Icons.route_outlined),
                  label: 'Viaggi',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_rounded),
                  label: 'Modello',
                ),
              ],
            ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.polyline_rounded, color: DriveColors.accent, size: 28),
      SizedBox(width: 10),
      Flexible(
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(
          'DriveMap',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -.8,
          ),
        )),
      ),
    ],
  );
}
