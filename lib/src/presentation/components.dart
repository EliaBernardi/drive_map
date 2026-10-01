import 'package:flutter/material.dart';

abstract final class DriveColors {
  static const background = Color(0xFF0C1118);
  static const surface = Color(0xFF151D27);
  static const border = Color(0xFF293440);
  static const accent = Color(0xFF7AE0C4);
  static const muted = Color(0xFF9CABB9);
  static const amber = Color(0xFFFFBE79);
  static const red = Color(0xFFFF8585);
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = 24, this.color});
  final Widget child;
  final double padding;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: color ?? DriveColors.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: DriveColors.border),
    ),
    child: child,
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: const TextStyle(color: DriveColors.muted, height: 1.5),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(
    this.label, {
    super.key,
    this.color = DriveColors.accent,
    this.icon,
  });
  final String label;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon ?? Icons.circle, color: color, size: icon == null ? 7 : 14),
        const SizedBox(width: 7),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Panel(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: DriveColors.accent),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: DriveColors.muted, height: 1.6),
              ),
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    ),
  );
}

class Metric extends StatelessWidget {
  const Metric(
    this.label,
    this.value,
    this.unit, {
    super.key,
    this.icon,
    this.color = DriveColors.accent,
  });
  final String label, value, unit;
  final IconData? icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Panel(
    padding: 20,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: DriveColors.muted, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 6,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(color: DriveColors.muted, fontSize: 12),
            ),
          ],
        ),
      ],
    ),
  );
}

String number(double? value, [int decimals = 0]) =>
    value?.toStringAsFixed(decimals) ?? '—';
String dateLabel(DateTime value) {
  final d = value.toLocal();
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} · ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

String durationLabel(double seconds) {
  final minutes = seconds ~/ 60;
  return minutes >= 60
      ? '${minutes ~/ 60} h ${minutes % 60} min'
      : '$minutes min ${seconds.toInt() % 60} s';
}

Future<void> showFailure(BuildContext context, Object error) async {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error.toString()),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
