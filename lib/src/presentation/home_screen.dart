import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/localization.dart';
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
          SectionTitle(
            context.l10n.homeTitle,
            subtitle: context.l10n.homeSubtitle,
          ),
          Panel(
            padding: 20,
            color: DriveColors.mint,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.garage,
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: DriveColors.accent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ford Fiesta',
                        style: TextStyle(
                          fontSize: 26,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.vehicleSpecs,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: DriveColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const DriveMapLogo(size: 112),
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
                  Expanded(child: Text(context.l10n.message(state.error!))),
                  IconButton(
                    onPressed: controller.dismissError,
                    icon: const Icon(Icons.close),
                    tooltip: context.l10n.dismissMessage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (state.demo && state.connection.ready) ...[
            StatusPill(
              context.l10n.demoActive,
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
          Text(
            context.l10n.foregroundNotice,
            style: const TextStyle(
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
                          ? context.l10n.tripPaused
                          : context.l10n.recordingActive
                    : context.l10n.nextTrip,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (state.hasTrip)
              Text(
                context.l10n.frameCount('${state.frameCount}'),
                style: const TextStyle(color: DriveColors.muted),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          state.hasTrip
              ? context.l10n.recordingNotice
              : context.l10n.startNotice,
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
                label: Text(context.l10n.startTrip),
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
                label: Text(
                  state.paused ? context.l10n.resume : context.l10n.pause,
                ),
              ),
              FilledButton.icon(
                onPressed: state.busy ? null : controller.stop,
                icon: const Icon(Icons.stop_rounded),
                label: Text(context.l10n.finishSave),
              ),
            ],
            if (state.savedTripId != null && !state.hasTrip)
              OutlinedButton.icon(
                onPressed: onTrips,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(context.l10n.savedOpenArchive),
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
                  context.l10n.obdConnection,
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
            state.connection.ready
                ? state.demo
                      ? context.l10n.simulator
                      : state.deviceName
                : 'OBDLink MX+',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.message(state.connection.message),
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
                  context.l10n.validReadings,
                ),
                _ConnectionMetric(
                  '${state.connection.latencyMs} ms',
                  context.l10n.lastResponse,
                ),
                _ConnectionMetric(
                  '${state.connection.reconnects}',
                  context.l10n.reconnections,
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
                  label: Text(context.l10n.openTelemetry),
                ),
                OutlinedButton.icon(
                  onPressed: state.busy ? null : c.disconnect,
                  icon: const Icon(Icons.link_off),
                  label: Text(context.l10n.disconnect),
                ),
              ],
            ),
          ] else ...[
            Text(
              context.l10n.connectInstructions,
              style: const TextStyle(
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
                          ? context.l10n.searching
                          : context.l10n.pairedDevices,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: connecting || state.busy ? null : c.pairing,
                    child: Text(context.l10n.pairDevice),
                  ),
                ],
              )
            else
              Text(
                context.l10n.desktopNotice,
                style: const TextStyle(color: DriveColors.amber),
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
                label: Text(context.l10n.diagnosticsLogs),
              ),
            if (connecting)
              TextButton(
                onPressed: c.disconnect,
                child: Text(context.l10n.cancelConnection),
              ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed:
                  connecting || state.busy || (state.hasTrip && !state.demo)
                  ? null
                  : () => c.connect(demo: true),
              icon: const Icon(Icons.science_outlined, size: 18),
              label: Text(context.l10n.exploreDemo),
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
