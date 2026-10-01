import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/telemetry.dart';
import '../features/analytics/trip_analyzer.dart';
import 'components.dart';

enum MapMetric { occupancy, fuel, relative, penalty }

class OperatingMap extends StatefulWidget {
  const OperatingMap({super.key, required this.analysis, this.compact = false});
  final TripAnalysis analysis;
  final bool compact;
  @override
  State<OperatingMap> createState() => _OperatingMapState();
}

class _OperatingMapState extends State<OperatingMap> {
  MapMetric _metric = MapMetric.occupancy;
  OperatingCell? _selected;
  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    final columns = a.cells.fold(12, (v, c) => math.max(v, c.rpmBin + 1));
    return Panel(
      padding: widget.compact ? 16 : 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            'La mappa del tuo motore',
            subtitle: widget.compact
                ? null
                : 'Dove ha lavorato il motore, e con quale costo osservato.',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in MapMetric.values)
                ChoiceChip(
                  label: Text(
                    [
                      'Permanenza',
                      'Carburante',
                      'Indice relativo',
                      'Penalità',
                    ][m.index],
                  ),
                  selected: _metric == m,
                  onSelected: (_) => setState(() => _metric = m),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (a.cells.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'Servono RPM e calculated load validi\nper costruire la mappa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: DriveColors.muted),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) => Semantics(
                label:
                    'Mappa operativa: ${a.cells.length} celle, ${durationLabel(a.validMapSeconds)} di dati validi. Tocca una cella per i dettagli.',
                child: GestureDetector(
                  onTapDown: (details) {
                    final rect = Rect.fromLTWH(
                      38,
                      18,
                      constraints.maxWidth - 46,
                      220,
                    );
                    if (!rect.contains(details.localPosition)) return;
                    final x =
                        ((details.localPosition.dx - rect.left) /
                                rect.width *
                                columns)
                            .floor();
                    final y =
                        (10 -
                                (details.localPosition.dy - rect.top) /
                                    rect.height *
                                    10)
                            .floor()
                            .clamp(0, 9);
                    setState(
                      () => _selected = a.cells
                          .where((c) => c.rpmBin == x && c.loadBin == y)
                          .firstOrNull,
                    );
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 280),
                    painter: _MapPainter(a.cells, _metric, columns, _selected),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 60,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(
                    colors: [
                      DriveColors.surface,
                      _metric == MapMetric.penalty
                          ? DriveColors.red
                          : DriveColors.accent,
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  switch (_metric) {
                    MapMetric.occupancy =>
                      'Da meno a più tempo · celle da 500 rpm × 10%',
                    MapMetric.fuel =>
                      'Flusso medio in l/h · solo dati disponibili',
                    MapMetric.relative =>
                      'Da 0 a 100 · favorevolezza secondo le regole',
                    MapMetric.penalty => 'Da 0 a 1 · costo medio delle zone',
                  },
                  style: const TextStyle(
                    color: DriveColors.muted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (_selected != null) ...[
            const Divider(height: 30),
            Text(
              '${_selected!.rpmBin * 500}–${(_selected!.rpmBin + 1) * 500} rpm · ${_selected!.loadBin * 10}–${(_selected!.loadBin + 1) * 10}% carico',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '${durationLabel(_selected!.seconds)} · ${_selected!.samples} frame\n'
              'Velocità media ${number(_selected!.meanSpeed, 1)} km/h · carburante ${number(_selected!.meanFuel, 2)} l/h\n'
              'Penalità ${number(_selected!.penalty, 2)} · contributo allo score zone −${a.validMapSeconds > 0 ? (_selected!.penaltySeconds / a.validMapSeconds * 100).toStringAsFixed(1) : '0'} punti',
              style: const TextStyle(color: DriveColors.muted, height: 1.7),
            ),
          ],
          if (!widget.compact) ...[
            const SizedBox(height: 18),
            const Text(
              'Mappa delle condizioni osservate. L’indice relativo descrive le regole del modello: non misura il rendimento termico o la BSFC.',
              style: TextStyle(
                color: DriveColors.muted,
                fontSize: 11,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.cells, this.metric, this.columns, this.selected);
  final List<OperatingCell> cells;
  final MapMetric metric;
  final int columns;
  final OperatingCell? selected;
  double? value(OperatingCell c) => switch (metric) {
    MapMetric.occupancy => c.seconds,
    MapMetric.fuel => c.meanFuel,
    MapMetric.relative => c.relativeIndex,
    MapMetric.penalty => c.penalty,
  };
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(38, 18, size.width - 46, 220);
    final width = rect.width / columns, height = rect.height / 10;
    final maximum = cells.fold(0.0, (v, c) => math.max(v, value(c) ?? 0));
    for (var x = 0; x < columns; x++) {
      for (var y = 0; y < 10; y++) {
        final cell = cells
            .where((c) => c.rpmBin == x && c.loadBin == y)
            .firstOrNull;
        final v = cell == null ? null : value(cell);
        final amount = v == null
            ? 0.0
            : metric == MapMetric.penalty
            ? v
            : metric == MapMetric.relative
            ? v / 100
            : maximum > 0
            ? v / maximum
            : 0.0;
        final color = v == null
            ? const Color(0xFF202A35)
            : Color.lerp(
                const Color(0xFF23443F),
                metric == MapMetric.penalty
                    ? DriveColors.red
                    : DriveColors.accent,
                amount.clamp(0, 1),
              )!;
        final box = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rect.left + x * width + 1.5,
            rect.top + (9 - y) * height + 1.5,
            math.max(1, width - 3),
            height - 3,
          ),
          const Radius.circular(3),
        );
        canvas.drawRRect(box, Paint()..color = color);
        if (cell != null && cell == selected) {
          canvas.drawRRect(
            box,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    }
    for (final percent in [0, 20, 40, 60, 80, 100]) {
      paintText(
        canvas,
        '$percent',
        Offset(3, rect.bottom - percent / 100 * rect.height - 6),
        size: 10,
      );
    }
    paintText(canvas, 'Carico %', Offset(rect.left, 0), size: 10);
    for (var i = 0; i <= 4; i++) {
      final rpm = (columns * 500 * i / 4).round();
      paintText(
        canvas,
        '${rpm ~/ 1000}${rpm % 1000 == 0 ? '' : '.${(rpm % 1000) ~/ 100}'}k',
        Offset(
          rect.left + rect.width * i / 4 - (i == 4 ? 16 : 0),
          rect.bottom + 10,
        ),
        size: 10,
      );
    }
    paintText(
      canvas,
      'Regime motore · rpm',
      Offset(rect.left, rect.bottom + 28),
      size: 10,
    );
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) =>
      oldDelegate.cells != cells ||
      oldDelegate.metric != metric ||
      oldDelegate.selected != selected;
}

class TelemetryTimeline extends StatefulWidget {
  const TelemetryTimeline({super.key, required this.analysis});
  final TripAnalysis analysis;
  @override
  State<TelemetryTimeline> createState() => _TelemetryTimelineState();
}

class _TelemetryTimelineState extends State<TelemetryTimeline> {
  Pid _pid = Pid.rpm;
  int? _selected;
  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    final f = _selected == null || _selected! >= a.frames.length
        ? null
        : a.frames[_selected!];
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Il viaggio, istante per istante',
            subtitle: 'Tocca il grafico per leggere un campione. I punti arancioni indicano eventi di guida.',
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final p in [
                Pid.rpm,
                Pid.speed,
                Pid.load,
                Pid.throttle,
                Pid.coolant,
                Pid.fuelRate,
              ])
                ChoiceChip(
                  label: Text(p.label),
                  selected: _pid == p,
                  onSelected: (_) => setState(() => _pid = p),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            f == null
                ? '${_pid.label} · ${_pid.unit}'
                : '${number(f[_pid], 1)} ${_pid.unit} · ${f.at.toLocal().toIso8601String().substring(11, 19)}',
            style: const TextStyle(color: DriveColors.accent),
          ),
          LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              onTapDown: (details) =>
                  _select(details.localPosition.dx, constraints.maxWidth),
              onHorizontalDragUpdate: (details) =>
                  _select(details.localPosition.dx, constraints.maxWidth),
              child: Semantics(
                label: 'Timeline ${_pid.label}. ${a.frames.length} campioni.',
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 220),
                  painter: _TimelinePainter(a, _pid, _selected),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _select(double x, double width) {
    final frames = widget.analysis.frames;
    if (frames.isEmpty) return;
    final ratio = ((x - 42) / (width - 54)).clamp(0.0, 1.0);
    final target =
        frames.first.at.microsecondsSinceEpoch +
        (frames.last.at.microsecondsSinceEpoch -
                frames.first.at.microsecondsSinceEpoch) *
            ratio;
    var index = 0;
    var distance = double.infinity;
    for (var i = 0; i < frames.length; i++) {
      final d = (frames[i].at.microsecondsSinceEpoch - target).abs();
      if (d < distance) {
        distance = d;
        index = i;
      }
    }
    setState(() => _selected = index);
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter(this.analysis, this.pid, this.selected);
  final TripAnalysis analysis;
  final Pid pid;
  final int? selected;
  @override
  void paint(Canvas canvas, Size size) {
    final frames = analysis.frames;
    if (frames.length < 2) {
      paintText(canvas, 'Campioni insufficienti', const Offset(20, 100));
      return;
    }
    final values = frames.map((f) => f[pid]).whereType<double>();
    if (values.isEmpty) {
      paintText(
        canvas,
        'Parametro non disponibile in questo viaggio',
        const Offset(10, 100),
      );
      return;
    }
    final minimum = math.min(0.0, values.reduce(math.min));
    final maximum = math.max(minimum + 1, values.reduce(math.max) * 1.1);
    final rect = Rect.fromLTWH(42, 22, size.width - 54, 160);
    final start = frames.first.at.microsecondsSinceEpoch;
    final elapsed = math.max(1, frames.last.at.microsecondsSinceEpoch - start);
    double x(DateTime time) =>
        rect.left +
        (time.microsecondsSinceEpoch - start) / elapsed * rect.width;
    double y(double v) =>
        rect.bottom - (v - minimum) / (maximum - minimum) * rect.height;
    for (var i = 0; i < 4; i++) {
      final yy = rect.top + rect.height * i / 3;
      canvas.drawLine(
        Offset(rect.left, yy),
        Offset(rect.right, yy),
        Paint()
          ..color = DriveColors.border
          ..strokeWidth = 1,
      );
      paintText(
        canvas,
        (maximum - (maximum - minimum) * i / 3).toStringAsFixed(0),
        Offset(0, yy - 5),
        size: 10,
      );
    }
    final path = Path();
    bool drawing = false;
    TelemetryFrame? previous;
    // Draw all points to preserve extrema; typical MVP trips remain manageable.
    for (final f in frames) {
      final v = f[pid];
      if (v == null) {
        drawing = false;
        previous = f;
        continue;
      }
      if (previous != null &&
          (previous.segment != f.segment ||
              f.at.difference(previous.at).inMilliseconds > 1500)) {
        drawing = false;
      }
      if (drawing) {
        path.lineTo(x(f.at), y(v));
      } else {
        path.moveTo(x(f.at), y(v));
      }
      drawing = true;
      previous = f;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = DriveColors.accent
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    for (final e in analysis.events) {
      canvas.drawCircle(
        Offset(x(e.at), rect.top + 3),
        3,
        Paint()..color = DriveColors.amber,
      );
    }
    if (selected != null && selected! < frames.length) {
      final f = frames[selected!];
      canvas.drawLine(
        Offset(x(f.at), rect.top),
        Offset(x(f.at), rect.bottom),
        Paint()..color = Colors.white54,
      );
      if (f[pid] != null) {
        canvas.drawCircle(
          Offset(x(f.at), y(f[pid]!)),
          4,
          Paint()..color = Colors.white,
        );
      }
    }
    for (var i = 0; i <= 3; i++) {
      paintText(
        canvas,
        '${(elapsed / 1e6 / 60 * i / 3).toStringAsFixed(1)}m',
        Offset(
          rect.left + rect.width * i / 3 - (i == 3 ? 28 : 0),
          rect.bottom + 14,
        ),
        size: 10,
      );
    }
  }

  @override
  bool shouldRepaint(_TimelinePainter oldDelegate) =>
      oldDelegate.analysis != analysis ||
      oldDelegate.pid != pid ||
      oldDelegate.selected != selected;
}

void paintText(
  Canvas canvas,
  String text,
  Offset offset, {
  double size = 11,
  Color color = DriveColors.muted,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: size),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, offset);
}
