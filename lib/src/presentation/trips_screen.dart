import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/localization.dart';
import '../domain/telemetry.dart';
import '../domain/trip.dart';
import '../features/analytics/trip_analyzer.dart';
import '../features/trips/csv_importer.dart';
import '../providers.dart';
import 'charts.dart';
import 'components.dart';

class TripsScreen extends ConsumerStatefulWidget {
  const TripsScreen({super.key});
  @override
  ConsumerState<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends ConsumerState<TripsScreen> {
  final Set<String> _selected = {};
  bool _importing = false;
  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    final activeTrip = ref.watch(dashboardProvider.select((s) => s.tripId));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            context.l10n.tripsTitle,
            subtitle: context.l10n.tripsSubtitle,
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _importing ? null : _import,
                icon: const Icon(Icons.file_upload_outlined),
                label: Text(
                  _importing ? context.l10n.importing : context.l10n.importData,
                ),
              ),
              OutlinedButton.icon(
                onPressed: _selected.length == 2
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ComparisonScreen(ids: _selected.toList()),
                        ),
                      )
                    : null,
                icon: const Icon(Icons.compare_arrows),
                label: Text(context.l10n.compareCount('${_selected.length}')),
              ),
              IconButton(
                onPressed: () => ref.invalidate(tripsProvider),
                icon: const Icon(Icons.refresh),
                tooltip: context.l10n.refreshTrips,
              ),
            ],
          ),
          const SizedBox(height: 24),
          trips.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyPanel(
              icon: Icons.storage_outlined,
              title: context.l10n.archiveUnavailable,
              message: context.l10n.error(error),
              action: OutlinedButton(
                onPressed: () {
                  ref.invalidate(databaseProvider);
                  ref.invalidate(tripsProvider);
                },
                child: Text(context.l10n.retry),
              ),
            ),
            data: (items) => items.isEmpty
                ? EmptyPanel(
                    icon: Icons.route_outlined,
                    title: context.l10n.firstTrip,
                    message: context.l10n.firstTripNotice,
                  )
                : Column(
                    children: [
                      for (final trip in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Panel(
                            padding: 18,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _selected.contains(trip.id),
                                  onChanged: trip.id == activeTrip
                                      ? null
                                      : (value) => setState(() {
                                          if (value == true) {
                                            if (_selected.length < 2) {
                                              _selected.add(trip.id);
                                            }
                                          } else {
                                            _selected.remove(trip.id);
                                          }
                                        }),
                                ),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: trip.id == activeTrip
                                        ? null
                                        : () => _open(trip.id),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            context.l10n.message(trip.name),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            dateLabel(trip.startedAt),
                                            style: const TextStyle(
                                              color: DriveColors.muted,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 6,
                                            children: [
                                              StatusPill(
                                                trip.source == TripSource.demo
                                                    ? 'DEMO'
                                                    : trip.source ==
                                                          TripSource.csv
                                                    ? context.l10n.importedCsv
                                                    : context.l10n.realObd,
                                                color:
                                                    trip.source ==
                                                        TripSource.demo
                                                    ? DriveColors.amber
                                                    : DriveColors.accent,
                                              ),
                                              if (trip.status == 'interrupted')
                                                StatusPill(
                                                  context
                                                      .l10n
                                                      .interruptedRecovered,
                                                  color: DriveColors.amber,
                                                ),
                                              if (trip.id == activeTrip)
                                                StatusPill(
                                                  context.l10n.openSession,
                                                  color: DriveColors.amber,
                                                ),
                                              Text(
                                                context.l10n.frameCount(
                                                  '${trip.frameCount}',
                                                ),
                                                style: const TextStyle(
                                                  color: DriveColors.muted,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: trip.id == activeTrip
                                      ? null
                                      : () => _open(trip.id),
                                  icon: const Icon(Icons.arrow_forward),
                                  tooltip: context.l10n.analyzeTrip,
                                ),
                                PopupMenuButton<String>(
                                  enabled: trip.id != activeTrip,
                                  onSelected: (_) => _delete(trip),
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text(context.l10n.deleteTrip),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _open(String id) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => TripAnalysisScreen(id: id)));
  Future<void> _delete(Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteTripQuestion),
        content: Text(
          context.l10n.deleteTripNotice(context.l10n.message(trip.name)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await (await ref.read(databaseProvider.future)).deleteTrip(trip.id);
      if (!mounted) return;
      setState(() => _selected.remove(trip.id));
      ref.invalidate(tripsProvider);
      ref.invalidate(tripDetailProvider(trip.id));
      ref.invalidate(analysisProvider(trip.id));
    } catch (error) {
      if (mounted) await showFailure(context, error);
    }
  }

  Future<void> _import() async {
    setState(() => _importing = true);
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'json'],
      );
      if (files.isEmpty) return;
      final bytes = await files.first.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 30 * 1024 * 1024) {
        throw FormatException(context.l10n.fileSizeLimit);
      }
      final text = utf8.decode(bytes);
      if (!mounted) return;
      if (files.first.name.toLowerCase().endsWith('.json')) {
        await _importBundle(text);
      } else {
        final preview = CsvPreview.parse(text);
        final request = await showDialog<CsvImportResult>(
          context: context,
          builder: (_) => CsvImportDialog(preview: preview),
        );
        if (request == null || !mounted) return;
        final config = await ref.read(settingsProvider.future);
        final id = DateTime.now().microsecondsSinceEpoch.toString();
        final frames = request.frames;
        final trip = Trip(
          id: id,
          name: files.first.name,
          startedAt: frames.first.at,
          endedAt: frames.last.at,
          source: TripSource.csv,
          status: 'completed',
          configJson: config.encode(),
        );
        await _saveImport(trip, frames, []);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.importResult(
                  '${frames.length}',
                  '${request.discardedRows}',
                  '${request.invalidValues}',
                ),
              ),
            ),
          );
        }
      }
      if (mounted) ref.invalidate(tripsProvider);
    } catch (error) {
      if (mounted) await showFailure(context, error);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _saveImport(
    Trip trip,
    List<TelemetryFrame> frames,
    List<RawSample> raw,
  ) async {
    final db = await ref.read(databaseProvider.future);
    final analysis = TripAnalyzer.analyze(
      frames,
      ScoreConfig.decode(trip.configJson),
    );
    await db.transaction(() async {
      await db.createTrip(trip, frames.expand((f) => f.values.keys).toSet());
      await db.append(trip.id, frames, raw);
      await db.saveAnalysis(trip.id, analysis);
    });
  }

  Future<void> _importBundle(String text) async {
    final json = jsonDecode(text) as Map<String, dynamic>;
    if (json['format'] != 'drivemap-1') {
      throw FormatException(context.l10n.unknownBundle);
    }
    final config = ScoreConfig.decode(jsonEncode(json['config']));
    final list = json['frames'] as List;
    if (list.length < 2 || list.length > 200000) {
      throw FormatException(context.l10n.invalidFrameCount);
    }
    final frames =
        list
            .map(
              (f) =>
                  TelemetryFrame.fromJson((f as Map).cast<String, dynamic>()),
            )
            .toList()
          ..sort((a, b) => a.at.compareTo(b.at));
    final rawList = json['raw'] as List? ?? [];
    if (rawList.length > 1000000) {
      throw FormatException(context.l10n.tooManyRaw);
    }
    final raw = rawList
        .map(
          (e) => RawSample(
            at: DateTime.parse(e['timestamp'] as String),
            pid: Pid.values.firstWhere((p) => p.hex == e['pid']),
            value: (e['value'] as num?)?.toDouble(),
            response: e['response'] as String,
            latencyMs: e['latency_ms'] as int,
            quality: SampleQuality.values.byName(e['quality'] as String),
          ),
        )
        .toList();
    final trip = Trip(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String,
      vehicle: json['vehicle'] as String,
      startedAt: frames.first.at,
      endedAt: frames.last.at,
      source: TripSource.values.byName(json['source'] as String),
      status: 'completed',
      configJson: config.encode(),
    );
    await _saveImport(trip, frames, raw);
  }
}

class TripAnalysisScreen extends ConsumerWidget {
  const TripAnalysisScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(analysisProvider(id));
    final data = ref.watch(tripDetailProvider(id)).asData?.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          data == null
              ? context.l10n.tripAnalysis
              : context.l10n.message(data.trip.name),
        ),
        actions: [
          PopupMenuButton<String>(
            enabled: data != null,
            onSelected: (value) => _export(context, ref, value),
            icon: const Icon(Icons.file_download_outlined),
            tooltip: context.l10n.exportTrip,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'bundle',
                child: Text(context.l10n.exportBundle),
              ),
              PopupMenuItem(
                value: 'csv',
                child: Text(context.l10n.exportTelemetry),
              ),
              PopupMenuItem(value: 'raw', child: Text(context.l10n.exportRaw)),
            ],
          ),
        ],
      ),
      body: analysis.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(context.l10n.error(error))),
        data: (a) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data != null) ...[
                    Text(
                      '${data.trip.vehicle} · ${dateLabel(data.trip.startedAt)}',
                      style: const TextStyle(color: DriveColors.muted),
                    ),
                    const SizedBox(height: 12),
                    if (data.trip.source == TripSource.demo)
                      StatusPill(
                        context.l10n.demoTripNotice,
                        color: DriveColors.amber,
                      ),
                    if (data.trip.source == TripSource.csv)
                      StatusPill(
                        context.l10n.csvTripNotice,
                        color: DriveColors.amber,
                      ),
                  ],
                  const SizedBox(height: 20),
                  _Summary(analysis: a),
                  const SizedBox(height: 20),
                  ScorePanel(analysis: a),
                  const SizedBox(height: 20),
                  OperatingMap(analysis: a),
                  const SizedBox(height: 20),
                  TelemetryTimeline(analysis: a),
                  const SizedBox(height: 20),
                  Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(
                          context.l10n.tripEvents,
                          subtitle: context.l10n.eventCount(
                            '${a.events.length}',
                          ),
                        ),
                        if (a.events.isEmpty)
                          Text(
                            context.l10n.noEvents,
                            style: const TextStyle(color: DriveColors.muted),
                          ),
                        for (final event in a.events.take(100))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.bolt,
                              color: DriveColors.amber,
                            ),
                            title: Text(context.l10n.message(event.label)),
                            subtitle: Text(dateLabel(event.at)),
                            trailing: Text(
                              '${event.value.toStringAsFixed(1)} m/s²',
                            ),
                          ),
                        if (a.events.length > 100)
                          Text(context.l10n.firstHundredEvents),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref, String type) async {
    try {
      final data = await ref.read(tripDetailProvider(id).future);
      final raw = type == 'csv'
          ? <Map<String, Object?>>[]
          : await (await ref.read(databaseProvider.future)).rawSamples(id);
      final String content;
      if (type == 'bundle') {
        content = jsonEncode({
          'format': 'drivemap-1',
          'name': data.trip.name,
          'vehicle': data.trip.vehicle,
          'source': data.trip.source.name,
          'config': jsonDecode(data.trip.configJson),
          'frames': data.frames.map((f) => f.toJson()).toList(),
          'raw': raw,
        });
      } else if (type == 'raw') {
        const columns = [
          'timestamp',
          'pid',
          'value',
          'unit',
          'quality',
          'latency_ms',
          'response',
        ];
        content = csv.encode([
          columns,
          for (final row in raw) [for (final key in columns) row[key] ?? ''],
        ]);
      } else {
        content = CsvImporter.export(data.frames);
      }
      final typeName = switch (type) {
        'bundle' => 'dati',
        'raw' => 'raw',
        _ => 'telemetria',
      };
      final extension = type == 'bundle' ? 'json' : 'csv';
      final saved = await FilePicker.saveFile(
        fileName:
            'drivemap_${_fileTimestamp(data.trip.startedAt)}_$typeName.$extension',
        bytes: Uint8List.fromList(utf8.encode(content)),
        mimeType: extension == 'json' ? 'application/json' : 'text/csv',
      );
      if (context.mounted && saved != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.exportCompleted)));
      }
    } catch (error) {
      if (context.mounted) await showFailure(context, error);
    }
  }

  String _fileTimestamp(DateTime value) {
    final time = value.toLocal();
    String two(int part) => part.toString().padLeft(2, '0');
    return '${time.year}${two(time.month)}${two(time.day)}_${two(time.hour)}${two(time.minute)}${two(time.second)}';
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.analysis});
  final TripAnalysis analysis;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = constraints.maxWidth > 750 ? 4 : 2;
      final a = analysis;
      final metrics = [
        Metric(context.l10n.observedTime, durationLabel(a.duration), ''),
        Metric(context.l10n.integratedDistance, number(a.distanceKm, 2), 'km'),
        Metric(context.l10n.integratedFuel, number(a.fuelLiters, 2), 'l'),
        Metric(
          context.l10n.estimatedConsumption,
          number(a.consumption, 1),
          'l/100 km',
        ),
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final metric in metrics)
                SizedBox(
                  width: (constraints.maxWidth - (count - 1) * 12) / count,
                  child: metric,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.coverageNotice(
              '${(a.speedCoverage * 100).round()}',
              '${(a.fuelCoverage * 100).round()}',
            ),
            style: const TextStyle(
              color: DriveColors.muted,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      );
    },
  );
}

class ScorePanel extends StatelessWidget {
  const ScorePanel({super.key, required this.analysis});
  final TripAnalysis analysis;
  @override
  Widget build(BuildContext context) {
    final a = analysis;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.yourScore,
                      style: const TextStyle(
                        color: DriveColors.accent,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: number(a.score),
                            style: const TextStyle(
                              color: DriveColors.ink,
                              fontSize: 56,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(
                            text: ' / 100',
                            style: TextStyle(
                              color: DriveColors.muted,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                context.l10n.explainable,
                icon: Icons.insights_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.analysisExplanation(a),
            style: const TextStyle(color: DriveColors.muted, height: 1.6),
          ),
          const SizedBox(height: 24),
          for (final part in a.parts)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(context.l10n.message(part.name))),
                      Text(
                        part.value == null
                            ? context.l10n.notCalculated
                            : '${part.value!.round()}/100',
                        style: TextStyle(
                          color: part.value == null
                              ? DriveColors.muted
                              : DriveColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (part.value ?? 0) / 100,
                    minHeight: 5,
                    borderRadius: BorderRadius.circular(5),
                    color: DriveColors.accent,
                    backgroundColor: DriveColors.border,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${context.l10n.message(part.reason)}\n${part.value == null || a.effectiveWeight == 0 ? context.l10n.excludedWeight('${(part.coverage * 100).round()}') : context.l10n.effectiveWeight('${(part.coverage * 100).round()}', (part.weight / a.effectiveWeight * 100).toStringAsFixed(1), (part.value! * part.weight / a.effectiveWeight).toStringAsFixed(1))}',
                    style: const TextStyle(
                      color: DriveColors.muted,
                      fontSize: 11,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class ComparisonScreen extends ConsumerWidget {
  const ComparisonScreen({super.key, required this.ids});
  final List<String> ids;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = ref.watch(analysisProvider(ids[0]));
    final second = ref.watch(analysisProvider(ids[1]));
    final one = ref.watch(tripDetailProvider(ids[0])).asData?.value;
    final two = ref.watch(tripDetailProvider(ids[1])).asData?.value;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.compareTrips)),
      body: first.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.error(e))),
        data: (a) => second.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(context.l10n.error(e))),
          data: (b) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.comparisonNotice,
                  style: const TextStyle(color: DriveColors.muted, height: 1.6),
                ),
                if (one?.trip.configJson != two?.trip.configJson)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: StatusPill(
                      context.l10n.differentModels,
                      color: DriveColors.amber,
                    ),
                  ),
                if (one?.trip.source != two?.trip.source)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: StatusPill(
                      context.l10n.differentSources,
                      color: DriveColors.amber,
                    ),
                  ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text(context.l10n.metric)),
                      DataColumn(
                        label: Text(
                          one == null
                              ? context.l10n.tripA
                              : context.l10n.message(one.trip.name),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          two == null
                              ? context.l10n.tripB
                              : context.l10n.message(two.trip.name),
                        ),
                      ),
                    ],
                    rows: [
                      _row(
                        context.l10n.scoreMetric,
                        number(a.score),
                        number(b.score),
                      ),
                      _row(
                        context.l10n.distanceMetric,
                        number(a.distanceKm, 2),
                        number(b.distanceKm, 2),
                      ),
                      _row(
                        context.l10n.consumptionMetric,
                        number(a.consumption, 1),
                        number(b.consumption, 1),
                      ),
                      _row(
                        context.l10n.favorableZones,
                        '${(a.favorableFraction * 100).round()}%',
                        '${(b.favorableFraction * 100).round()}%',
                      ),
                      _row(
                        context.l10n.drivingEvents,
                        '${a.events.length}',
                        '${b.events.length}',
                      ),
                      _row(
                        context.l10n.mappedTime,
                        durationLabel(a.validMapSeconds),
                        durationLabel(b.validMapSeconds),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) => constraints.maxWidth > 1000
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: OperatingMap(analysis: a, compact: true),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OperatingMap(analysis: b, compact: true),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            OperatingMap(analysis: a, compact: true),
                            const SizedBox(height: 20),
                            OperatingMap(analysis: b, compact: true),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataRow _row(String label, String a, String b) => DataRow(
    cells: [DataCell(Text(label)), DataCell(Text(a)), DataCell(Text(b))],
  );
}

class CsvImportDialog extends StatefulWidget {
  const CsvImportDialog({super.key, required this.preview});
  final CsvPreview preview;
  @override
  State<CsvImportDialog> createState() => _CsvImportDialogState();
}

class _CsvImportDialogState extends State<CsvImportDialog> {
  late int _time;
  late Map<Pid, int> _mapping;
  bool _elapsed = false;
  String? _error;
  late final TextEditingController _origin;
  @override
  void initState() {
    super.initState();
    _time = widget.preview.guessTime();
    _mapping = {for (final p in Pid.values) p: widget.preview.guess(p)};
    _origin = TextEditingController(
      text: DateTime.now().toUtc().toIso8601String(),
    );
    if (_time >= 0 && widget.preview.rows.first.length > _time) {
      _elapsed =
          double.tryParse(
            widget.preview.rows.first[_time].toString().replaceAll(',', '.'),
          ) !=
          null;
    }
  }

  @override
  void dispose() {
    _origin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.mapCsvColumns),
    content: SizedBox(
      width: 560,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.csvPreview('${widget.preview.rows.length}'),
              style: const TextStyle(color: DriveColors.muted, height: 1.5),
            ),
            const SizedBox(height: 18),
            _column(context.l10n.time, _time, (v) => setState(() => _time = v)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.elapsedSeconds),
              subtitle: Text(context.l10n.isoTimeNotice),
              value: _elapsed,
              onChanged: (v) => setState(() => _elapsed = v),
            ),
            if (_elapsed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _origin,
                  decoration: InputDecoration(
                    labelText: context.l10n.tripStartIso,
                  ),
                ),
              ),
            for (final p in Pid.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _column(
                  '${context.l10n.pidLabel(p.code)} · ${p.unit}',
                  _mapping[p]!,
                  (v) => setState(() => _mapping[p] = v),
                ),
              ),
            if (_error != null)
              Text(
                context.l10n.message(_error!),
                style: const TextStyle(color: DriveColors.red),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(
        onPressed: () {
          try {
            final origin = DateTime.tryParse(_origin.text);
            if (_elapsed &&
                (origin == null ||
                    !RegExp(r'(Z|[+-]\d\d:\d\d)$').hasMatch(_origin.text))) {
              throw FormatException(context.l10n.invalidOrigin);
            }
            final result = CsvImporter.convert(
              widget.preview,
              _time,
              {
                for (final e in _mapping.entries)
                  if (e.value >= 0) e.key: e.value,
              },
              elapsedSeconds: _elapsed,
              origin: origin ?? DateTime.now().toUtc(),
            );
            Navigator.pop(context, result);
          } catch (error) {
            setState(() => _error = context.l10n.error(error));
          }
        },
        child: Text(context.l10n.importTrip),
      ),
    ],
  );
  Widget _column(String label, int value, ValueChanged<int> onChanged) =>
      DropdownButtonFormField<int>(
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: [
          DropdownMenuItem(value: -1, child: Text(context.l10n.notPresent)),
          for (var i = 0; i < widget.preview.headers.length; i++)
            DropdownMenuItem(
              value: i,
              child: Text(
                '${i + 1}. ${widget.preview.headers[i]}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      );
}
