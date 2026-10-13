import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'drive_map_logo.dart';

enum MainDestination {
  home('Home', Icons.home_outlined, Icons.home_rounded),
  telemetry('Telemetria', Icons.speed_outlined, Icons.speed_rounded),
  trips('Viaggi', Icons.route_outlined, Icons.route_rounded),
  profile('Profilo', Icons.person_outline_rounded, Icons.person_rounded);

  const MainDestination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon, selectedIcon;
}

/// Common, compact chrome. Page state and Bluetooth ownership live in the shell.
class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.body,
    required this.destination,
    required this.onDestinationSelected,
    required this.connectionLabel,
    required this.connectionColor,
  });

  final Widget body;
  final MainDestination destination;
  final ValueChanged<MainDestination> onDestinationSelected;
  final String connectionLabel;
  final Color connectionColor;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: DriveColors.mint,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: DriveColors.border, offset: Offset(0, 3)),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 7, 20, 10),
                  child: Row(
                    children: [
                      const DriveMapLogo(size: 46),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'DRIVE MAP',
                              style: TextStyle(
                                fontSize: 17,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w800,
                                color: DriveColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Tooltip(
                        message: connectionLabel,
                        child: Semantics(
                          label: 'Collegamento OBD: $connectionLabel',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bluetooth_rounded,
                                size: 17,
                                color: connectionColor,
                              ),
                              if (MediaQuery.sizeOf(context).width >= 360 &&
                                  MediaQuery.textScalerOf(context).scale(12) <=
                                      18) ...[
                                const SizedBox(width: 5),
                                Text(
                                  connectionLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: connectionColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: body,
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        color: DriveColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: DriveColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SizedBox(
              height: 52 + MediaQuery.textScalerOf(context).scale(11),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    for (final item in MainDestination.values)
                      Expanded(
                        child: _NavigationItem(
                          destination: item,
                          selected: item == destination,
                          onTap: () => onDestinationSelected(item),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });
  final MainDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: destination.label,
    onTap: onTap,
    excludeSemantics: true,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: selected ? DriveColors.mint : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.controlRadius),
        child: InkWell(
          key: ValueKey('navigation-${destination.name}'),
          borderRadius: BorderRadius.circular(AppTheme.controlRadius),
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  size: 22,
                  color: selected ? DriveColors.accent : DriveColors.muted,
                ),
                const SizedBox(height: 3),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: selected ? DriveColors.accent : DriveColors.muted,
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
