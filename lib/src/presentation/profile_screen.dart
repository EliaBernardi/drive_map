import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'components.dart';
import 'drive_map_logo.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceName = ref.watch(dashboardProvider.select((s) => s.deviceName));
    return SingleChildScrollView(
      key: const PageStorageKey('profile'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Il tuo veicolo.',
            subtitle: 'La tua Fiesta e gli strumenti di bordo.',
          ),
          const Panel(
            child: Column(
              children: [
                DriveMapLogo(size: 128),
                SizedBox(height: 14),
                Text(
                  'Ford Fiesta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.6,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '2021 · 1.0 EcoBoost',
                  style: TextStyle(color: DriveColors.muted),
                ),
                SizedBox(height: 24),
                _ProfileRow(
                  icon: Icons.bolt_rounded,
                  label: 'Motore',
                  value: '125 CV · mild hybrid',
                ),
                Divider(height: 28),
                _ProfileRow(
                  icon: Icons.local_gas_station_outlined,
                  label: 'Alimentazione',
                  value: 'Benzina',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Panel(
            padding: 20,
            child: _ProfileRow(
              icon: Icons.bluetooth_rounded,
              label: 'Adattatore',
              value: deviceName.isEmpty ? 'OBDLink MX+' : deviceName,
            ),
          ),
          const SizedBox(height: 20),
          Panel(
            padding: 8,
            child: ListTile(
              key: const ValueKey('analysis-settings'),
              leading: const Icon(
                Icons.tune_rounded,
                color: DriveColors.accent,
              ),
              title: const Text(
                'Parametri di analisi',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('Personalizza soglie e pesi della guida.'),
              trailing: const Icon(Icons.chevron_right_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Parametri di analisi')),
                    body: const SettingsScreen(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'I viaggi restano sul tuo telefono. Puoi esportarli dalla sezione Viaggi per consultarli anche sul computer.',
            style: TextStyle(
              fontSize: 12,
              color: DriveColors.muted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: DriveColors.mint,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: DriveColors.accent, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: DriveColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    ],
  );
}
