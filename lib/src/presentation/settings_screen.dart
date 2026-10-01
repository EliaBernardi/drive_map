import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              Text(error.toString()),
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
                child: const Text('Ripristina modello iniziale'),
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
            const SectionTitle(
              'Uno score che puoi capire.',
              subtitle:
                  'Regole esplicite, pesi modificabili e nessuna scatola nera.',
            ),
            const Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(
                    'Modello euristico · rules-1.0.0',
                    icon: Icons.science_outlined,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Le impostazioni si applicano ai nuovi viaggi. Ogni viaggio conserva la propria configurazione, così lo score può essere ricalcolato in modo riproducibile.',
                    style: TextStyle(height: 1.6),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Calculated load è un proxy del carico. L’indice relativo rappresenta la favorevolezza delle zone secondo queste regole; non è una misura di coppia, potenza o rendimento termico.',
                    style: TextStyle(color: DriveColors.muted, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _group(
              'Il peso di ogni componente',
              'I pesi vengono rinormalizzati sulle componenti disponibili. Valori iniziali: 0,40 / 0,25 / 0,20 / 0,15.',
              {
                'zoneWeight': 'Zone operative',
                'smoothWeight': 'Regolarità',
                'warmupWeight': 'Riscaldamento',
                'economyWeight': 'Consumo relativo',
              },
            ),
            const SizedBox(height: 20),
            _group(
              'Le zone del motore',
              'Favorevole: regime tra le soglie e carico tra 20% e soglia alta. Sfavorevole: alto regime, oppure basso regime con carico elevato.',
              {
                'lowRpm': 'Regime minimo favorevole · rpm',
                'highRpm': 'Soglia alto regime · rpm',
                'highLoad': 'Soglia alto carico · %',
              },
            ),
            const SizedBox(height: 20),
            _group(
              'Riscaldamento e regolarità',
              'Le accelerazioni sono derivate dai timestamp originali della velocità OBD. Gli eventi sono conteggiati all’ingresso nella condizione e rapportati al minuto.',
              {
                'warmTemperature': 'Fine riscaldamento · °C',
                'coldLoad': 'Carico consentito a freddo · %',
                'hardAcceleration': 'Accelerazione brusca · m/s²',
                'hardBraking': 'Frenata brusca · m/s²',
              },
            ),
            const SizedBox(height: 20),
            _group(
              'Baseline di consumo',
              'Imposta 0 per escludere la componente economy. Una baseline deve provenire da viaggi comparabili per percorso, temperatura e traffico. La sola quantità di carburante non misura l’efficienza.',
              {'baselineConsumption': 'Consumo di riferimento · l/100 km'},
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.check),
                  label: Text(_saving ? 'Salvataggio…' : 'Salva modello'),
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
                  child: const Text('Valori iniziali'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Profilo di studio: Ford Fiesta 2021 · OBDLink MX+\nAcquisizione mobile in primo piano. Android: RFCOMM. iOS: ExternalAccessory, previa configurazione e abilitazione del produttore. Desktop: importazione e analisi.\nNessuna scrittura ECU o cancellazione errori è esposta nell’app.',
              style: TextStyle(
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Modello salvato per i prossimi viaggi.'),
          ),
        );
      }
    } catch (error) {
      if (mounted) await showFailure(context, error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
