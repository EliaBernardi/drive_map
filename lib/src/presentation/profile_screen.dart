import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/localization.dart';
import '../providers.dart';
import '../localization/locale_controller.dart';
import 'components.dart';
import 'drive_map_logo.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(
      dashboardProvider.select((s) => (name: s.deviceName, demo: s.demo)),
    );
    return SingleChildScrollView(
      key: const PageStorageKey('profile'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            context.l10n.profileTitle,
            subtitle: context.l10n.profileSubtitle,
          ),
          const _LanguagePicker(),
          const SizedBox(height: 20),
          Panel(
            child: Column(
              children: [
                const DriveMapLogo(size: 128),
                const SizedBox(height: 14),
                const Text(
                  'Ford Fiesta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '2021 · 1.0 EcoBoost',
                  style: TextStyle(color: DriveColors.muted),
                ),
                const SizedBox(height: 24),
                _ProfileRow(
                  icon: Icons.bolt_rounded,
                  label: context.l10n.engine,
                  value: context.l10n.engineSpecs,
                ),
                const Divider(height: 28),
                _ProfileRow(
                  icon: Icons.local_gas_station_outlined,
                  label: context.l10n.fuelType,
                  value: context.l10n.petrol,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Panel(
            padding: 20,
            child: _ProfileRow(
              icon: Icons.bluetooth_rounded,
              label: context.l10n.adapter,
              value: device.demo
                  ? context.l10n.simulator
                  : device.name.isEmpty
                  ? 'OBDLink MX+'
                  : device.name,
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
              title: Text(
                context.l10n.analysisSettings,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(context.l10n.analysisSettingsSubtitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: Text(context.l10n.analysisSettings)),
                    body: const SettingsScreen(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.localTripsNotice,
            style: const TextStyle(
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

class _LanguagePicker extends ConsumerStatefulWidget {
  const _LanguagePicker();

  @override
  ConsumerState<_LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends ConsumerState<_LanguagePicker> {
  bool _saving = false;
  int _selectionVersion = 0;

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(localeProvider);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate_rounded, color: DriveColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.l10n.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_saving || language.isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.languageHint,
            style: const TextStyle(color: DriveColors.muted, height: 1.5),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            // Recreate only this form field when restoration/selection changes.
            key: ValueKey(
              'app-language-${language.asData?.value.languageCode ?? 'loading'}-$_selectionVersion',
            ),
            initialValue: language.asData?.value.languageCode ?? 'it',
            isExpanded: true,
            decoration: InputDecoration(labelText: context.l10n.language),
            items: [
              DropdownMenuItem(
                value: 'it',
                child: Text(context.l10n.languageItalian),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text(context.l10n.languageEnglish),
              ),
            ],
            onChanged: _saving || language.asData == null
                ? null
                : (value) async {
                    if (value == null ||
                        value == language.asData?.value.languageCode) {
                      return;
                    }
                    setState(() => _saving = true);
                    try {
                      await ref.read(localeProvider.notifier).select(value);
                    } catch (_) {
                      if (!context.mounted) return;
                      // Restore the displayed selection if persistence failed.
                      _selectionVersion++;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.languageSaveFailed),
                        ),
                      );
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
          ),
          if (language.hasError) ...[
            const SizedBox(height: 10),
            Text(context.l10n.languageLoadFailed),
            TextButton(
              onPressed: () => ref.invalidate(localeProvider),
              child: Text(context.l10n.retry),
            ),
          ],
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
