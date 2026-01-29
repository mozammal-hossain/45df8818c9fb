import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/di/injection.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/dashboard/dashboard_page.dart';
import 'package:device_vital_monitor_flutter_app/presentation/history/bloc/history_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/history/history_page.dart';
import 'package:device_vital_monitor_flutter_app/presentation/settings/settings_page.dart';

/// Root scaffold with bottom navigation for Monitor, History, and Settings.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const DashboardPage(),
          BlocProvider(
            create: (_) => getIt<HistoryBloc>()..add(const HistoryRequested()),
            child: const HistoryPage(),
          ),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: l10n.dashboardTitle,
                  selected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                  scheme: scheme,
                ),
                _NavItem(
                  icon: Icons.history_rounded,
                  label: l10n.historyTitle,
                  selected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                  scheme: scheme,
                ),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: l10n.settingsTitle,
                  selected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                  scheme: scheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
