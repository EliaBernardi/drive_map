import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/localization.dart';
import '../features/analytics/trip_analyzer.dart';
import '../providers.dart';
import 'components.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(settingsProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.error(error)),
              TextButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(settingsProvider.notifier)
                        .save(const ScoreConfig());
                  } catch (e) {
                    if (context.mounted) await showFailure(context, e);
                  }
                },
                child: Text(context.l10n.restoreModel),
              ),
            ],
          ),
        ),
        data: (config) =>
            _SettingsForm(key: ValueKey(config.encode()), config: config),
      );
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({super.key, required this.config});
  final ScoreConfig config;
  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  late final Map<String, TextEditingController> _fields;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _fields = {
      for (final e in widget.config.toJson().entries)
        if (e.value is double)
          e.key: TextEditingController(text: (e.value as double).toString()),
    };
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              context.l10n.settingsTitle,
              subtitle: context.l10n.settingsSubtitle,
            ),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(
                    context.l10n.heuristicModel,
                    icon: Icons.science_outlined,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.settingsNotice,
                    style: const TextStyle(height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.loadNotice,
                    style: const TextStyle(
                      color: DriveColors.muted,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _group(context.l10n.componentWeights, context.l10n.weightsNotice, {
              'zoneWeight': context.l10n.operatingZones,
              'smoothWeight': context.l10n.smoothness,
              'warmupWeight': context.l10n.warmup,
              'economyWeight': context.l10n.relativeEconomy,
            }),
            const SizedBox(height: 20),
            _group(context.l10n.engineZones, context.l10n.engineZonesNotice, {
              'lowRpm': context.l10n.lowRpm,
              'highRpm': context.l10n.highRpm,
              'highLoad': context.l10n.highLoad,
            }),
            const SizedBox(height: 20),
            _group(
              context.l10n.warmupSmoothness,
              context.l10n.accelerationNotice,
              {
                'warmTemperature': context.l10n.warmTemperature,
                'coldLoad': context.l10n.coldLoad,
                'hardAcceleration': context.l10n.hardAccelerationThreshold,
                'hardBraking': context.l10n.hardBrakingThreshold,
              },
            ),
            const SizedBox(height: 20),
            _group(context.l10n.economyBaseline, context.l10n.baselineNotice, {
              'baselineConsumption': context.l10n.baselineConsumption,
            }),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.check),
                  label: Text(
                    _saving ? context.l10n.saving : context.l10n.saveModel,
                  ),
                ),
                OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () {
                          final defaults = const ScoreConfig().toJson();
                          for (final e in _fields.entries) {
                            e.value.text = defaults[e.key].toString();
                          }
                        },
                  child: Text(context.l10n.defaults),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              context.l10n.studyProfile,
              style: const TextStyle(
                color: DriveColors.muted,
                fontSize: 12,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _group(String title, String subtitle, Map<String, String> fields) =>
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(title, subtitle: subtitle),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final e in fields.entries)
                    SizedBox(
                      width: constraints.maxWidth > 580
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth,
                      child: TextField(
                        controller: _fields[e.key],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(labelText: e.value),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      double value(String key) =>
          double.parse(_fields[key]!.text.replaceAll(',', '.'));
      final config = ScoreConfig(
        zoneWeight: value('zoneWeight'),
        smoothWeight: value('smoothWeight'),
        warmupWeight: value('warmupWeight'),
        economyWeight: value('economyWeight'),
        lowRpm: value('lowRpm'),
        highRpm: value('highRpm'),
        highLoad: value('highLoad'),
        coldLoad: value('coldLoad'),
        warmTemperature: value('warmTemperature'),
        hardAcceleration: value('hardAcceleration'),
        hardBraking: value('hardBraking'),
        baselineConsumption: value('baselineConsumption'),
      );
      await ref.read(settingsProvider.notifier).save(config);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.modelSaved)));
      }
    } catch (error) {
      if (mounted) await showFailure(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
