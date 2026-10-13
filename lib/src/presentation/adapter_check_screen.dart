import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../localization/localization.dart';
import '../domain/telemetry.dart';
import '../features/obd/adapter_check.dart';

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
                  context.l10n.connectObdLink,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(context.l10n.scanInstructions),
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
                  label: Text(context.l10n.addObd),
                ),
                if (!_android)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(context.l10n.androidScanOnly),
                  ),
                if (check.showDevices) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.bluetoothDevices,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (check.scanning)
                        TextButton(
                          onPressed: check.stopScan,
                          child: Text(context.l10n.stopSearch),
                        )
                      else if (!check.busy && !check.connected)
                        IconButton(
                          tooltip: context.l10n.searchAgain,
                          onPressed: check.scan,
                          icon: const Icon(Icons.refresh),
                        ),
                    ],
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.onlyObdLink),
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
                            ? context.l10n.scanningNearby
                            : context.l10n.noVisibleDevices,
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
                                ? context.l10n.unnamedDevice
                                : device.name,
                          ),
                          subtitle: Text(
                            '${device.id} · ${device.paired ? context.l10n.alreadyPaired : context.l10n.notPaired}',
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
                  context.l10n.statusLabel(context.l10n.message(check.status)),
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
                      context.l10n.message(check.error!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (check.selected != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      context.l10n.selectedDevice(check.selected!.name),
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
                            context.l10n.standardPids,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(context.l10n.message(check.pidStatus)),
                          if (check.ecu != null ||
                              check.protocol.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (check.ecu != null)
                                  context.l10n.ecuLabel(check.ecu!),
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
                                    label: Text(_pidLabel(context, code)),
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
                        child: Text(context.l10n.repeatAti),
                      ),
                    if (check.connected || check.busy)
                      OutlinedButton(
                        onPressed: check.disconnect,
                        child: Text(
                          check.connected
                              ? context.l10n.disconnect
                              : context.l10n.cancel,
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
                                SnackBar(content: Text(context.l10n.error(e))),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.settings_bluetooth),
                        label: Text(context.l10n.bluetoothSettings),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () => _exportLogs(context),
                  icon: const Icon(Icons.download_outlined),
                  label: Text(context.l10n.exportLogs),
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10n.commandsResponses,
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
                        ? context.l10n.noCommands
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

  String _pidLabel(BuildContext context, int code) {
    final hex = code.toRadixString(16).padLeft(2, '0').toUpperCase();
    for (final pid in Pid.values) {
      if (pid.code == code) {
        return 'PID $hex · ${context.l10n.pidLabel(pid.code)}';
      }
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
            context.l10n.pidTestTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(context.l10n.pidTestNotice),
          if (check.pidTestRunning) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: check.pidTestProgress),
          ],
          if (check.pidTestMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              check.pidTestRunning
                  ? context.l10n.testProgress('${check.pidTestElapsedSeconds}')
                  : context.l10n.message(check.pidTestMessage!),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (check.pidTestResults.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              context.l10n.testConsumption,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              check.averageConsumptionLPer100Km == null
                  ? context.l10n.testConsumptionUnavailable
                  : '${check.averageConsumptionLPer100Km!.toStringAsFixed(1)} L/100 km',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              context.l10n.testConsumptionNotice(
                check.testDistanceKm.toStringAsFixed(3),
                check.testFuelLiters.toStringAsFixed(4),
              ),
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
                                  '${context.l10n.pidLabel(result.code)} · ${result.hex}',
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
                                      ? context.l10n.noValidSamples(
                                          '${result.failedSamples}',
                                        )
                                      : context.l10n.sampleSummary(
                                              _testNumber(
                                                result.average,
                                                result.code,
                                              ),
                                              result.unit,
                                              _testNumber(
                                                result.minimum,
                                                result.code,
                                              ),
                                              _testNumber(
                                                result.maximum,
                                                result.code,
                                              ),
                                              '${result.validSamples}',
                                            ) +
                                            (result.failedSamples == 0
                                                ? ''
                                                : context.l10n.failedSamples(
                                                    '${result.failedSamples}',
                                                  )),
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
              label: Text(context.l10n.stopTest),
            )
          else if (check.connected)
            FilledButton.icon(
              onPressed: check.busy || check.testablePids.isEmpty
                  ? null
                  : check.runPidTest,
              icon: const Icon(Icons.monitor_heart_outlined),
              label: Text(context.l10n.startPidTest),
            ),
          if (check.connected && check.testablePids.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(context.l10n.noTestablePids),
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
      context.l10n.diagnosticLog,
      context.l10n.logExported(now.toIso8601String()),
      context.l10n.logDevice(check.selected?.name ?? context.l10n.none),
      context.l10n.logConnection(context.l10n.message(check.status)),
      context.l10n.logPids(context.l10n.message(check.pidStatus)),
      context.l10n.logEcu(check.ecu ?? context.l10n.notDetected),
      context.l10n.logProtocol(
        check.protocol.isEmpty
            ? context.l10n.protocolNotDetected
            : check.protocol,
      ),
      context.l10n.logPidList(
        check.supportedPids.isEmpty
            ? context.l10n.noPidsDetected
            : (check.supportedPids.toList()..sort()).join(', '),
      ),
      '',
      context.l10n.serialEvents,
      if (check.log.isEmpty) context.l10n.noLogEvents else ...check.log,
    ];
    try {
      final saved = await FilePicker.saveFile(
        fileName: fileName,
        bytes: Uint8List.fromList(utf8.encode(lines.join('\n'))),
        mimeType: 'text/plain',
      );
      if (!context.mounted || saved == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.logSaved(saved.toString()))),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.exportFailed(context.l10n.error(e))),
        ),
      );
    }
  }
}
