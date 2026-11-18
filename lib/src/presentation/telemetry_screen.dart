import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/localization.dart';
import '../domain/telemetry.dart';
import '../providers.dart';
import 'components.dart';

class TelemetryScreen extends ConsumerWidget {
  const TelemetryScreen({super.key, required this.onHome});
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final frame = state.frame;
    return SingleChildScrollView(
      key: const PageStorageKey('telemetry'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(context.l10n.telemetryTitle),
          if (state.hasTrip) ...[
            Panel(
              padding: 14,
              child: Row(
                children: [
                  Icon(
                    state.paused
                        ? Icons.pause_circle_outline
                        : Icons.fiber_manual_record,
                    color: state.paused ? DriveColors.amber : DriveColors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.paused
                          ? context.l10n.tripPaused
                          : context.l10n.recordingInProgress,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton(
                    onPressed: onHome,
                    child: Text(context.l10n.manage),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          _LivePanel(state: state),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 760
                  ? 3
                  : constraints.maxWidth >= 340
                  ? 2
                  : 1;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final pid in [
                    Pid.load,
                    Pid.throttle,
                    Pid.fuelLevel,
                    Pid.fuelRate,
                    Pid.manifold,
                    Pid.voltage,
                  ])
                    SizedBox(
                      width: (constraints.maxWidth - (count - 1) * 14) / count,
                      child: Metric(
                        context.l10n.pidLabel(pid.code),
                        number(
                          frame?[pid],
                          pid == Pid.fuelRate || pid == Pid.voltage ? 1 : 0,
                        ),
                        pid.unit,
                        icon: switch (pid) {
                          Pid.fuelLevel => Icons.local_gas_station_rounded,
                          Pid.fuelRate => Icons.local_gas_station_outlined,
                          Pid.load => Icons.speed_rounded,
                          Pid.manifold => Icons.air_rounded,
                          Pid.voltage => Icons.bolt_rounded,
                          _ => Icons.tune_rounded,
                        },
                      ),
                    ),
                ],
              );
            },
          ),
          if (state.connection.ready) ...[
            const SizedBox(height: 20),
            Panel(
              padding: 8,
              child: ExpansionTile(
                title: Text(context.l10n.availableParameters),
                subtitle: Text(context.l10n.ecuLabel(state.connection.ecu)),
                childrenPadding: const EdgeInsets.all(12),
                shape: const Border(),
                collapsedShape: const Border(),
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 8,
                    children: [
                      for (final pid in Pid.values)
                        StatusPill(
                          '${context.l10n.pidLabel(pid.code)} · ${state.connection.supported.contains(pid) ? context.l10n.available : context.l10n.unsupported}',
                          color: state.connection.supported.contains(pid)
                              ? DriveColors.accent
                              : DriveColors.muted,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.connection.protocol,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DriveColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            context.l10n.missingParameters,
            style: const TextStyle(fontSize: 12, color: DriveColors.muted),
          ),
        ],
      ),
    );
  }
}

class _LivePanel extends StatelessWidget {
  const _LivePanel({required this.state});
  final DashboardState state;
  @override
  Widget build(BuildContext context) => Panel(
    padding: 18,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.liveTelemetry,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: DriveColors.muted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            StatusPill(
              state.recording
                  ? 'REC'
                  : state.connection.ready
                  ? 'LIVE'
                  : 'OFFLINE',
              color: state.recording ? DriveColors.red : DriveColors.muted,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 218,
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 7,
                child: Transform.translate(
                  offset: const Offset(4, 0),
                  child: _RadialGauge(
                    label: context.l10n.pidLabel(Pid.rpm.code),
                    value: state.frame?[Pid.rpm],
                    maximum: 8000,
                    maximumLabel: '8k',
                    unit: 'rpm',
                    color: DriveColors.grass,
                  ),
                ),
              ),
              Expanded(
                flex: 13,
                child: _RadialGauge(
                  label: context.l10n.pidLabel(Pid.speed.code),
                  value: state.frame?[Pid.speed],
                  maximum: 220,
                  maximumLabel: '220',
                  unit: 'km/h',
                  color: DriveColors.accent,
                  prominent: true,
                ),
              ),
              Expanded(
                flex: 7,
                child: Transform.translate(
                  offset: const Offset(-4, 0),
                  child: _RadialGauge(
                    label: context.l10n.pidLabel(Pid.coolant.code),
                    value: state.frame?[Pid.coolant],
                    maximum: 130,
                    maximumLabel: '130',
                    unit: '°C',
                    color: DriveColors.amber,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          state.frame == null
              ? context.l10n.waitingData
              : context.l10n.screenRefresh,
          style: const TextStyle(color: DriveColors.muted, fontSize: 11),
        ),
      ],
    ),
  );
}

class _RadialGauge extends StatelessWidget {
  const _RadialGauge({
    required this.label,
    required this.value,
    required this.maximum,
    required this.maximumLabel,
    required this.unit,
    required this.color,
    this.prominent = false,
  });

  final String label;
  final double? value;
  final double maximum;
  final String maximumLabel;
  final String unit;
  final Color color;
  final bool prominent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: prominent ? 2 : 1),
    child: Column(
      children: [
        SizedBox(
          height: 24,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: DriveColors.muted,
                fontSize: prominent ? 12 : 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final radius = math.min(width, height) / 2 - 7;
              final endpointOffset = radius * math.sqrt(.5);
              final labelWidth = prominent ? 38.0 : 26.0;
              final labelTop = height / 2 + endpointOffset + 3;
              final startX = width / 2 - endpointOffset - labelWidth / 2;
              final endX = width / 2 + endpointOffset - labelWidth / 2;
              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(
                    painter: _DialPainter(
                      value: value,
                      maximum: maximum,
                      color: color,
                      ticks: prominent ? 45 : 31,
                      prominent: prominent,
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: prominent ? 20 : 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              number(value),
                              style: TextStyle(
                                fontSize: prominent ? 70 : 21,
                                height: 1,
                                fontWeight: FontWeight.w800,
                                letterSpacing: prominent ? -2 : -.5,
                                color: DriveColors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unit,
                            style: TextStyle(
                              color: DriveColors.muted,
                              fontSize: prominent ? 12 : 9,
                              letterSpacing: prominent ? 1.4 : .3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: startX,
                    top: labelTop,
                    width: labelWidth,
                    child: Text(
                      '0',
                      textAlign: TextAlign.center,
                      style: _scaleStyle,
                    ),
                  ),
                  Positioned(
                    left: endX,
                    top: labelTop,
                    width: labelWidth,
                    child: Text(
                      maximumLabel,
                      textAlign: TextAlign.center,
                      style: _scaleStyle,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );

  static const _scaleStyle = TextStyle(
    color: DriveColors.muted,
    fontSize: 9,
    height: 1,
  );
}

class _DialPainter extends CustomPainter {
  const _DialPainter({
    required this.value,
    required this.maximum,
    required this.color,
    required this.ticks,
    required this.prominent,
  });

  final double? value;
  final double maximum;
  final Color color;
  final int ticks;
  final bool prominent;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.max(0.0, math.min(size.width, size.height) / 2 - 7);
    final center = Offset(size.width / 2, size.height / 2);
    final fraction = value == null ? 0.0 : (value! / maximum).clamp(0.0, 1.0);
    final start = math.pi * .75;
    final sweep = math.pi * 1.5;
    for (var i = 0; i < ticks; i++) {
      final position = i / (ticks - 1);
      final angle = start + sweep * position;
      final active = value != null && value! >= 0 && position <= fraction;
      final tickLength = prominent ? 10.0 : 7.0;
      final paint = Paint()
        ..color = active ? color : DriveColors.border
        ..strokeWidth = prominent ? 3 : 2.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center +
            Offset(math.cos(angle), math.sin(angle)) * (radius - tickLength),
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.maximum != maximum ||
      oldDelegate.color != color ||
      oldDelegate.ticks != ticks ||
      oldDelegate.prominent != prominent;
}
