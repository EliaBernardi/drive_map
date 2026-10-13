import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          const SectionTitle(
            'Il motore, dal vivo.',
            subtitle: 'Uno sguardo ai valori della centralina.',
          ),
          if (!state.connection.ready) ...[
            EmptyPanel(
              icon: Icons.bluetooth_searching_rounded,
              title: 'In attesa della tua auto',
              message: state.connection.message,
              action: FilledButton.icon(
                onPressed: onHome,
                icon: const Icon(Icons.home_rounded),
                label: const Text('Collega dalla Home'),
              ),
            ),
            const SizedBox(height: 20),
          ],
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
                          ? 'Viaggio in pausa'
                          : 'Registrazione in corso',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton(onPressed: onHome, child: const Text('Gestisci')),
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
                    Pid.coolant,
                    Pid.fuelRate,
                    Pid.manifold,
                    Pid.voltage,
                  ])
                    SizedBox(
                      width: (constraints.maxWidth - (count - 1) * 14) / count,
                      child: Metric(
                        pid.label,
                        number(
                          frame?[pid],
                          pid == Pid.fuelRate || pid == Pid.voltage ? 1 : 0,
                        ),
                        pid.unit,
                        icon: switch (pid) {
                          Pid.coolant => Icons.thermostat_rounded,
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
                title: const Text('Parametri disponibili'),
                subtitle: Text('ECU ${state.connection.ecu}'),
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
                          '${pid.label} · ${state.connection.supported.contains(pid) ? 'disponibile' : 'non supportato'}',
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
          const Text(
            'I parametri non disponibili sono indicati con —.',
            style: TextStyle(fontSize: 12, color: DriveColors.muted),
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
    child: Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'TELEMETRIA LIVE',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: DriveColors.muted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            StatusPill(
              state.recording ? 'REC' : 'LIVE',
              color: state.recording ? DriveColors.red : DriveColors.muted,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 218,
          width: double.infinity,
          child: CustomPaint(
            painter: _GaugePainter(state.frame?[Pid.speed]),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    number(state.frame?[Pid.speed]),
                    style: const TextStyle(
                      fontSize: 76,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'km/h',
                    style: TextStyle(
                      color: DriveColors.muted,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speed, color: DriveColors.accent, size: 20),
            const SizedBox(width: 10),
            Text(
              number(state.frame?[Pid.rpm]),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            const Text('rpm', style: TextStyle(color: DriveColors.muted)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          state.frame == null
              ? 'In attesa dei dati del veicolo'
              : 'Schermo aggiornato ogni 0,5 s',
          style: const TextStyle(color: DriveColors.muted, fontSize: 11),
        ),
      ],
    ),
  );
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.speed);
  final double? speed;
  @override
  void paint(Canvas canvas, Size size) {
    final radius = math.min(size.width / 2 - 12, 104.0);
    final center = Offset(size.width / 2, size.height / 2 + 6);
    for (var i = 0; i < 45; i++) {
      final angle = math.pi * .75 + (math.pi * 1.5 * i / 44);
      final active = speed != null && i / 44 < speed! / 180;
      final paint = Paint()
        ..color = active ? DriveColors.accent : DriveColors.border
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center + Offset(math.cos(angle), math.sin(angle)) * (radius - 11),
        center + Offset(math.cos(angle), math.sin(angle)) * radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) => oldDelegate.speed != speed;
}
