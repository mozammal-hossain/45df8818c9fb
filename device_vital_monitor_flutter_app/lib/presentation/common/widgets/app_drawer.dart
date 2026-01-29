import 'package:flutter/material.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';

/// App drawer with navigation items. [onDashboard], [onHistory], [onSettings]
/// are called when the user taps the corresponding tile (drawer is not closed here).
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.onDashboard,
    required this.onHistory,
    required this.onSettings,
  });

  final VoidCallback onDashboard;
  final VoidCallback onHistory;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final padding = AppInsets.pagePadding(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primaryContainer),
            padding: EdgeInsets.fromLTRB(
              padding.left,
              padding.top,
              padding.right,
              padding.bottom,
            ),
            child: Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text(l10n.dashboardTitle),
            onTap: onDashboard,
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(l10n.historyTitle),
            onTap: onHistory,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settingsTitle),
            onTap: onSettings,
          ),
        ],
      ),
    );
  }
}
