import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/di/injection.dart';
import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/core/layout/responsive.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/common/widgets/app_drawer.dart';
import 'package:device_vital_monitor_flutter_app/presentation/dashboard/bloc/dashboard_bloc.dart'
    show
        DashboardBloc,
        DashboardState,
        DashboardInitial,
        DashboardError,
        DashboardLoaded,
        LogStatusState,
        DashboardSensorDataRequested;
import 'package:device_vital_monitor_flutter_app/presentation/dashboard/widgets/battery_level_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/dashboard/widgets/log_status_button.dart';
import 'package:device_vital_monitor_flutter_app/presentation/dashboard/widgets/memory_usage_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/dashboard/widgets/thermal_state_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/history/bloc/history_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/history/history_page.dart';
import 'package:device_vital_monitor_flutter_app/presentation/settings/bloc/theme/theme_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/settings/settings_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void _fetchSensorData(BuildContext context) {
    context.read<DashboardBloc>().add(const DashboardSensorDataRequested());
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider(
          create: (_) => getIt<HistoryBloc>()..add(const HistoryRequested()),
          child: const HistoryPage(),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => const SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      drawer: AppDrawer(
        onDashboard: () => Navigator.of(context).pop(),
        onHistory: () => _openHistory(context),
        onSettings: () => _openSettings(context),
      ),
      floatingActionButton: const LogStatusButton(floating: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: () {
                  context.read<ThemeBloc>().add(const ThemeCycleRequested());
                },
                tooltip: l10n.toggleThemeTooltip,
              );
            },
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          switch (state) {
            case DashboardError(:final message):
              debugPrint('Dashboard error: $message');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            case DashboardLoaded(:final logStatus, :final logStatusMessage):
              if (logStatusMessage == null) break;
              switch (logStatus) {
                case LogStatusState.success:
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(logStatusMessage),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                    ),
                  );
                case LogStatusState.failure:
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(logStatusMessage),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                default:
                  break;
              }
            default:
              break;
          }
        },
        builder: (context, state) {
          if (state is DashboardInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) _fetchSensorData(context);
            });
          }
          final padding = AppInsets.pagePadding(context);
          final sM = AppInsets.spacingM(context);
          final wide = isWideScreen(context);
          final cols = gridColumns(context);
          return RefreshIndicator(
            onRefresh: () async => _fetchSensorData(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxW = constraints.maxWidth;
                  if (!wide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ThermalStateCard(),
                        SizedBox(height: sM),
                        const BatteryLevelCard(),
                        SizedBox(height: sM),
                        const MemoryUsageCard(),
                      ],
                    );
                  }
                  final gap = sM;
                  final cellWidth = (maxW - gap * (cols - 1)) / cols;
                  final cards = [
                    const ThermalStateCard(),
                    const BatteryLevelCard(),
                    const MemoryUsageCard(),
                  ];
                  final rows = <Widget>[];
                  for (var i = 0; i < cards.length; i += cols) {
                    final rowChildren = <Widget>[];
                    for (var j = 0; j < cols && i + j < cards.length; j++) {
                      if (j > 0) rowChildren.add(SizedBox(width: gap));
                      rowChildren.add(
                        SizedBox(width: cellWidth, child: cards[i + j]),
                      );
                    }
                    if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
                    rows.add(
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rowChildren,
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: rows,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
