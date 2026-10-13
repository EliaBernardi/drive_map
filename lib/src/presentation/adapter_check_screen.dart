import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../domain/telemetry.dart';
import '../features/obd/adapter_check.dart';
import '../features/obd/obd_transport.dart';

class AdapterCheckScreen extends StatefulWidget {
  const AdapterCheckScreen({super.key});

  @override
  State<AdapterCheckScreen> createState() => _AdapterCheckScreenState();
}

class _AdapterCheckScreenState extends State<AdapterCheckScreen>
    with WidgetsBindingObserver {
  final AdapterCheck check = AdapterCheck();
  bool get _android =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (check.connected) unawaited(check.disconnect());
    }
    if (state == AppLifecycleState.resumed &&
        check.showDevices &&
        !check.connected &&
        !check.busy &&
        !check.scanning) {
      unawaited(check.refreshDevices());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    check.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('DriveMap')),
    body: SafeArea(
      child: AnimatedBuilder(
        animation: check,
        builder: (context, _) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Collega la tua OBDLink',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Accendi il quadro e metti l’adattatore in modalità associazione. La ricerca usa Bluetooth Classic.',
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed:
                      !_android ||
                          check.busy ||
                          check.scanning ||
                          check.connected
                      ? null
                      : check.scan,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Aggiungi OBD'),
                ),
                if (!_android)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'La ricerca Bluetooth Classic è disponibile su Android.',
                    ),
                  ),
                if (check.showDevices) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Dispositivi Bluetooth',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (check.scanning)
                        TextButton(
                          onPressed: check.stopScan,
                          child: const Text('Ferma ricerca'),
                        )
                      else if (!check.busy && !check.connected)
                        IconButton(
                          tooltip: 'Cerca di nuovo',
                          onPressed: check.scan,
                          icon: const Icon(Icons.refresh),
                        ),
                    ],
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mostra solo OBDLink'),
                    value: check.onlyObdLink,
                    onChanged: check.setObdLinkFilter,
                  ),
                  if (check.scanning)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    ),
                  if (check.visibleDevices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        check.scanning
                            ? 'Ricerca in corso… Avvicina il telefono e attiva il pairing su MX+.'
                            : 'Nessun dispositivo visibile. Riprova o disattiva il filtro OBDLink.',
                      ),
                    ),
                  for (final device in check.visibleDevices)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.bluetooth),
                          title: Text(
                            device.name.isEmpty
                                ? 'Dispositivo senza nome'
                                : device.name,
                          ),
                          subtitle: Text(
                            '${device.id} · ${device.paired ? 'Già associato' : 'Da associare'}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          enabled: !check.busy && !check.connected,
                          onTap: () => check.selectAndConnect(device),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Stato: ${check.status}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (check.busy)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(),
                  ),
                if (check.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      check.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (check.selected != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Dispositivo selezionato: ${check.selected!.name}',
                    ),
                  ),
                if (check.connected) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PID standard disponibili',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(check.pidStatus),
                          if (check.ecu != null ||
                              check.protocol.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (check.ecu != null)
                                  'Centralina ${check.ecu}',
                                if (check.protocol.isNotEmpty) check.protocol,
                              ].join(' · '),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          if (check.supportedPids.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                for (final code
                                    in check.supportedPids.toList()..sort())
                                  Chip(
                                    label: Text(_pidLabel(code)),
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                if (check.connected || check.pidTestResults.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _pidTestPanel(context),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (check.connected)
                      OutlinedButton(
                        onPressed: check.busy ? null : check.identify,
                        child: const Text('Ripeti ATI'),
                      ),
                    if (check.connected || check.busy)
                      OutlinedButton(
                        onPressed: check.disconnect,
                        child: Text(
                          check.connected ? 'Disconnetti' : 'Annulla',
                        ),
                      ),
                    if (_android)
                      TextButton.icon(
                        onPressed: () async {
                          try {
                            await check.openPairing();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(readableError(e))),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.settings_bluetooth),
                        label: const Text('Impostazioni Bluetooth'),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () => _exportLogs(context),
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Esporta log in un file .txt'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Comandi e risposte',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    check.log.isEmpty
                        ? 'Nessun comando inviato.'
                        : check.log.reversed.join('\n'),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  String _pidLabel(int code) {
    final hex = code.toRadixString(16).padLeft(2, '0').toUpperCase();
    for (final pid in Pid.values) {
      if (pid.code == code) return 'PID $hex · ${pid.label}';
    }
    return 'PID $hex';
  }

  Widget _pidTestPanel(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test dei parametri · 30 secondi',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Interroga in sequenza i PID principali, il livello carburante e il contachilometri. Il carburante è espresso in percentuale, non in litri. Avvia il test a veicolo fermo; non usare il telefono durante la guida.',
          ),
          if (check.pidTestRunning) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: check.pidTestProgress),
          ],
          if (check.pidTestMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              check.pidTestRunning
                  ? 'Test in corso · ${check.pidTestElapsedSeconds} / 30 s'
                  : check.pidTestMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (check.pidTestResults.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Consumo medio stimato nel test',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              check.averageConsumptionLPer100Km == null
                  ? '— L/100 km · distanza troppo breve o letture non disponibili'
                  : '${check.averageConsumptionLPer100Km!.toStringAsFixed(1)} L/100 km',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Calcolato da portata carburante e velocità; non è una media storica. Distanza ${check.testDistanceKm.toStringAsFixed(3)} km · carburante stimato ${check.testFuelLiters.toStringAsFixed(4)} L.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final result in check.pidTestResults)
                      SizedBox(
                        width: width,
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${result.label} · ${result.hex}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${_testNumber(result.latest, result.code)}${result.latest == null ? '' : ' ${result.unit}'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                Text(
                                  result.validSamples == 0
                                      ? 'Nessun valore valido · ${result.failedSamples} risposte non valide'
                                      : 'Media ${_testNumber(result.average, result.code)} ${result.unit} · min ${_testNumber(result.minimum, result.code)} · max ${_testNumber(result.maximum, result.code)} · ${result.validSamples} letture${result.failedSamples == 0 ? '' : ' · ${result.failedSamples} senza dato'}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
          const SizedBox(height: 14),
          if (check.pidTestRunning)
            OutlinedButton.icon(
              onPressed: check.cancelPidTest,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Interrompi test'),
            )
          else if (check.connected)
            FilledButton.icon(
              onPressed: check.busy || check.testablePids.isEmpty
                  ? null
                  : check.runPidTest,
              icon: const Icon(Icons.monitor_heart_outlined),
              label: const Text('Avvia test PID 30 s'),
            ),
          if (check.connected && check.testablePids.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Nessun PID principale disponibile per il test.'),
            ),
        ],
      ),
    ),
  );

  String _testNumber(double? value, int code) {
    if (value == null) return '—';
    final decimals = code == 0x0C ? 0 : (code == 0xA6 ? 1 : 1);
    return value.toStringAsFixed(decimals);
  }

  Future<void> _exportLogs(BuildContext context) async {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    final fileName =
        '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}.txt';
    final lines = <String>[
      'DriveMap · log diagnostico',
      'Esportato: ${now.toIso8601String()}',
      'Dispositivo: ${check.selected?.name ?? 'nessuno'}',
      'Stato connessione: ${check.status}',
      'Stato PID: ${check.pidStatus}',
      'Centralina: ${check.ecu ?? 'non rilevata'}',
      'Protocollo: ${check.protocol.isEmpty ? 'non rilevato' : check.protocol}',
      'PID standard: ${check.supportedPids.isEmpty ? 'nessuno rilevato' : (check.supportedPids.toList()..sort()).join(', ')}',
      '',
      'Eventi e traffico seriale:',
      if (check.log.isEmpty)
        'Nessun evento registrato in questa sessione.'
      else
        ...check.log,
    ];
    try {
      final saved = await FilePicker.saveFile(
        fileName: fileName,
        bytes: Uint8List.fromList(utf8.encode(lines.join('\n'))),
        mimeType: 'text/plain',
      );
      if (!context.mounted || saved == null) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Log salvato in $saved')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Esportazione non riuscita: ${readableError(e)}'),
        ),
      );
    }
  }
}
