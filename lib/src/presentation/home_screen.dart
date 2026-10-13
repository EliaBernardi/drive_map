import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/obd/obd_session.dart';
import '../features/obd/obd_transport.dart';
import '../providers.dart';
import 'adapter_check_screen.dart';
import 'components.dart';
import 'drive_map_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
    required this.onTelemetry,
    required this.onTrips,
  });
  final VoidCallback onTelemetry, onTrips;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final controller = ref.read(dashboardProvider.notifier);
    final connecting = ![
      ConnectionPhase.ready,
      ConnectionPhase.failed,
      ConnectionPhase.disconnected,
    ].contains(state.connection.phase);
    return SingleChildScrollView(
      key: const PageStorageKey('home'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Si parte?',
            subtitle: 'La tua auto, un viaggio alla volta.',
          ),
          const Panel(
            padding: 20,
            color: DriveColors.mint,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEL TUO GARAGE',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: DriveColors.accent,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Ford Fiesta',
                        style: TextStyle(
                          fontSize: 26,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.6,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2021 · 1.0 EcoBoost\n125 CV · mild hybrid',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: DriveColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                DriveMapLogo(size: 112),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (state.error != null) ...[
            Panel(
              padding: 14,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: DriveColors.amber),
                  const SizedBox(width: 10),
                  Expanded(child: Text(state.error!)),
                  IconButton(
                    onPressed: controller.dismissError,
                    icon: const Icon(Icons.close),
                    tooltip: 'Chiudi messaggio',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (state.demo && state.connection.ready) ...[
            const StatusPill(
              'Demo attiva · dati simulati',
              color: DriveColors.amber,
              icon: Icons.science_outlined,
            ),
            const SizedBox(height: 16),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final connection = _connection(context, ref, state, connecting);
              final recording = _recording(context, state, controller);
              if (constraints.maxWidth >= 760) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: connection),
                    const SizedBox(width: 20),
                    Expanded(child: recording),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.connection.ready || state.hasTrip)
                    recording
                  else
                    connection,
                  const SizedBox(height: 20),
                  if (state.connection.ready || state.hasTrip)
                    connection
                  else
                    recording,
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'La raccolta si mette in pausa quando l’app passa in background. Lo schermo resta acceso mentre OBD è connesso.',
            style: TextStyle(
              fontSize: 12,
              color: DriveColors.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _recording(
    BuildContext context,
    DashboardState state,
    DashboardController controller,
  ) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              state.recording ? Icons.fiber_manual_record : Icons.route,
              color: state.recording ? DriveColors.red : DriveColors.accent,
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
              ? 'I dati vengono salvati sul telefono. Lascia DriveMap aperta durante il viaggio.'
              : 'Avvia prima di partire. Al termine potrai ritrovare ed esportare i tuoi dati in Viaggi.',
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
                    state.busy || (state.paused && !state.connection.ready)
                    ? null
                    : state.paused
                    ? controller.resume
                    : controller.pause,
                icon: Icon(state.paused ? Icons.play_arrow : Icons.pause),
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
  );

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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: onTelemetry,
                  icon: const Icon(Icons.speed_rounded),
                  label: const Text('Apri telemetria'),
                ),
                OutlinedButton.icon(
                  onPressed: state.busy ? null : c.disconnect,
                  icon: const Icon(Icons.link_off),
                  label: const Text('Disconnetti'),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'Accendi il quadro, chiudi le altre app OBD e seleziona il tuo adattatore.',
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
            if (!state.hasTrip && PlatformObdTransport.supported)
              TextButton.icon(
                onPressed: connecting || state.busy
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AdapterCheckScreen(),
                        ),
                      ),
                icon: const Icon(Icons.article_outlined, size: 18),
                label: const Text('Diagnostica e log OBD'),
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
