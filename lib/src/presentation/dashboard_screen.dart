import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/telemetry.dart';
import '../features/obd/obd_session.dart';
import '../features/obd/obd_transport.dart';
import '../providers.dart';
import 'components.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key, required this.onTrips});
  final VoidCallback onTrips;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final controller = ref.read(dashboardProvider.notifier);
    final frame = state.frame;
    final wide = MediaQuery.sizeOf(context).width > 1100;
    final connecting = ![
      ConnectionPhase.ready,
      ConnectionPhase.failed,
      ConnectionPhase.disconnected,
    ].contains(state.connection.phase);
    return SingleChildScrollView(
      padding: EdgeInsets.all(wide ? 36 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONOSCI IL TUO MOTORE',
            style: TextStyle(
              color: DriveColors.accent,
              letterSpacing: 2,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.recording
                ? 'Il viaggio è in corso.'
                : 'Ogni viaggio,\nun dato in più.',
            style: TextStyle(
              fontSize: wide ? 44 : 34,
              height: 1.12,
              letterSpacing: -1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.recording
                ? 'Concentrati sulla strada. DriveMap registra la telemetria.'
                : 'Dai dati della tua auto a una guida più consapevole.',
            style: const TextStyle(color: DriveColors.muted, height: 1.5),
          ),
          const SizedBox(height: 28),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Panel(
                padding: 16,
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: DriveColors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                    IconButton(
                      onPressed: controller.dismissError,
                      icon: const Icon(Icons.close),
                      tooltip: 'Chiudi messaggio',
                    ),
                  ],
                ),
              ),
            ),
          if (state.demo && state.connection.ready)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: StatusPill(
                'Demo attiva · dati simulati, salvati come dimostrativi',
                color: DriveColors.amber,
                icon: Icons.science_outlined,
              ),
            ),
          Flex(
            direction: wide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (wide)
                Expanded(flex: 5, child: _LivePanel(state: state))
              else
                _LivePanel(state: state),
              SizedBox(width: wide ? 20 : 0, height: wide ? 0 : 20),
              if (wide)
                Expanded(
                  flex: 4,
                  child: _connection(context, ref, state, connecting),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: _connection(context, ref, state, connecting),
                ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth > 750 ? 4 : 2;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final p in [
                    Pid.load,
                    Pid.throttle,
                    Pid.coolant,
                    Pid.fuelRate,
                  ])
                    SizedBox(
                      width: (constraints.maxWidth - (count - 1) * 14) / count,
                      child: Metric(
                        p.label,
                        number(frame?[p], p == Pid.fuelRate ? 1 : 0),
                        p.unit,
                        icon: switch (p) {
                          Pid.coolant => Icons.thermostat,
                          Pid.fuelRate => Icons.local_gas_station_outlined,
                          Pid.load => Icons.speed,
                          _ => Icons.tune,
                        },
                        color: p == Pid.coolant
                            ? DriveColors.amber
                            : DriveColors.accent,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      state.recording ? Icons.fiber_manual_record : Icons.route,
                      color: state.recording
                          ? DriveColors.red
                          : DriveColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.hasTrip
                            ? state.paused
                                  ? 'Viaggio in pausa'
                                  : 'Registrazione attiva'
                            : 'Il tuo prossimo viaggio',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (state.hasTrip)
                      Text(
                        '${state.frameCount} frame',
                        style: const TextStyle(color: DriveColors.muted),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  state.hasTrip
                      ? 'Salvataggio locale automatico. Le pause e le disconnessioni restano separate nell’analisi.'
                      : 'Collega l’adattatore, poi avvia la registrazione. Al termine troverai timeline, zone operative e score nell’archivio.',
                  style: const TextStyle(color: DriveColors.muted, height: 1.5),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (!state.hasTrip)
                      FilledButton.icon(
                        onPressed: state.connection.ready && !state.busy
                            ? controller.start
                            : null,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Inizia viaggio'),
                      ),
                    if (state.hasTrip) ...[
                      OutlinedButton.icon(
                        onPressed:
                            state.busy ||
                                (state.paused && !state.connection.ready)
                            ? null
                            : state.paused
                            ? controller.resume
                            : controller.pause,
                        icon: Icon(
                          state.paused ? Icons.play_arrow : Icons.pause,
                        ),
                        label: Text(state.paused ? 'Riprendi' : 'Pausa'),
                      ),
                      FilledButton.icon(
                        onPressed: state.busy ? null : controller.stop,
                        icon: const Icon(Icons.stop_rounded),
                        label: const Text('Termina e salva'),
                      ),
                    ],
                    if (state.savedTripId != null && !state.hasTrip)
                      OutlinedButton.icon(
                        onPressed: onTrips,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Viaggio salvato · apri archivio'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (state.connection.ready)
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    'Cosa ci racconta la tua auto',
                    subtitle: 'Disponibilità verificata sulla centralina selezionata.',
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final pid in Pid.values)
                        StatusPill(
                          '${pid.label} · ${state.connection.supported.contains(pid) ? 'disponibile' : 'non supportato'}',
                          color: state.connection.supported.contains(pid)
                              ? DriveColors.accent
                              : DriveColors.muted,
                          icon: state.connection.supported.contains(pid)
                              ? Icons.check
                              : Icons.remove,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${state.connection.protocol} · ECU ${state.connection.ecu}',
                    style: const TextStyle(
                      color: DriveColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            const Text(
              'Acquisizione in primo piano. In background il viaggio viene messo in pausa.\nI dati non disponibili sono indicati con —.',
              style: TextStyle(
                color: DriveColors.muted,
                fontSize: 12,
                height: 1.7,
              ),
            ),
        ],
      ),
    );
  }

  Widget _connection(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
    bool connecting,
  ) {
    final c = ref.read(dashboardProvider.notifier);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bluetooth_connected, color: DriveColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Connessione OBD',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (connecting || state.busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            state.connection.ready ? state.deviceName : 'OBDLink MX+',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            state.connection.message,
            style: const TextStyle(color: DriveColors.muted, height: 1.5),
          ),
          const SizedBox(height: 20),
          if (state.connection.ready) ...[
            Wrap(
              spacing: 20,
              runSpacing: 12,
              children: [
                _ConnectionMetric(
                  '${state.connection.responsesPerSecond.toStringAsFixed(1)} /s',
                  'Letture valide',
                ),
                _ConnectionMetric(
                  '${state.connection.latencyMs} ms',
                  'Ultima risposta',
                ),
                _ConnectionMetric(
                  '${state.connection.reconnects}',
                  'Riconnessioni',
                ),
              ],
            ),
            const SizedBox(height: 22),
            OutlinedButton.icon(
              onPressed: state.busy ? null : c.disconnect,
              icon: const Icon(Icons.link_off),
              label: const Text('Disconnetti'),
            ),
          ] else ...[
            const Text(
              '1  Inserisci MX+ e accendi il quadro.\n2  Associalo via Bluetooth e chiudi altre app OBD.\n3  Aggiorna l’elenco e scegli l’adattatore.',
              style: TextStyle(
                color: DriveColors.muted,
                height: 1.9,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            if (PlatformObdTransport.supported)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: connecting || state.loadingDevices || state.busy
                        ? null
                        : c.discover,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      state.loadingDevices
                          ? 'Ricerca…'
                          : 'Dispositivi associati',
                    ),
                  ),
                  OutlinedButton(
                    onPressed: connecting || state.busy ? null : c.pairing,
                    child: const Text('Associa dispositivo'),
                  ),
                ],
              )
            else
              const Text(
                'Su desktop: importa i viaggi o esplora la demo.',
                style: TextStyle(color: DriveColors.amber),
              ),
            for (final device in state.devices)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.bluetooth),
                title: Text(device.name),
                subtitle: Text(device.id, style: const TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right),
                onTap: connecting || state.busy
                    ? null
                    : () => c.connect(device: device),
              ),
            if (connecting)
              TextButton(
                onPressed: c.disconnect,
                child: const Text('Annulla connessione'),
              ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed:
                  connecting || state.busy || (state.hasTrip && !state.demo)
                  ? null
                  : () => c.connect(demo: true),
              icon: const Icon(Icons.science_outlined, size: 18),
              label: const Text('Esplora con la demo'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConnectionMetric extends StatelessWidget {
  const _ConnectionMetric(this.value, this.label);
  final String value, label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 5),
      Text(
        label,
        style: const TextStyle(color: DriveColors.muted, fontSize: 11),
      ),
    ],
  );
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
            const Text(
              'TELEMETRIA LIVE',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.5,
                color: DriveColors.muted,
              ),
            ),
            const Spacer(),
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
                      fontWeight: FontWeight.w300,
                      letterSpacing: -4,
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
              : 'Campioni sincronizzati · 500 ms',
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
