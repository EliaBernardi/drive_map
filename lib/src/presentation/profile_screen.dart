import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/localization.dart';
import '../providers.dart';
import '../localization/locale_controller.dart';
import 'components.dart';
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
          SectionTitle(context.l10n.profileTitle),
          Panel(
            padding: 18,
            child: Column(
              children: [
                const DriveMapMark(size: 128),
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
          const _LanguagePicker(),
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

  Future<void> _selectLanguage(String value) async {
    if (_saving ||
        ref.read(localeProvider).asData?.value.languageCode == value) {
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(localeProvider.notifier).select(value);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.languageSaveFailed)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LanguageFlagButton(
                flag: '🇮🇹',
                label: context.l10n.languageItalian,
                selected: language.asData?.value.languageCode == 'it',
                enabled: !_saving && language.asData != null,
                onTap: () => _selectLanguage('it'),
              ),
              const SizedBox(width: 24),
              _LanguageFlagButton(
                flag: '🇬🇧',
                label: context.l10n.languageEnglish,
                selected: language.asData?.value.languageCode == 'en',
                enabled: !_saving && language.asData != null,
                onTap: () => _selectLanguage('en'),
              ),
            ],
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

class _LanguageFlagButton extends StatelessWidget {
  const _LanguageFlagButton({
    required this.flag,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = selected ? 72.0 : 62.0;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? DriveColors.mint : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? DriveColors.accent
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: selected ? 2.5 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: DriveColors.accent.withValues(alpha: .15),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Text(flag, style: TextStyle(fontSize: selected ? 34 : 30)),
            ),
          ),
        ),
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
