import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/di/injection.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/bloc/dashboard/dashboard_bloc.dart'
    show DashboardBloc, DashboardState, DashboardInitial, DashboardError,
        DashboardLoaded, LogStatusState, DashboardSensorDataRequested;
import 'package:device_vital_monitor_flutter_app/presentation/bloc/history/history_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/bloc/settings/theme/theme_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/screens/dashboard/widgets/battery_level_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/screens/dashboard/widgets/log_status_button.dart';
import 'package:device_vital_monitor_flutter_app/presentation/screens/dashboard/widgets/memory_usage_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/screens/dashboard/widgets/thermal_state_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/screens/history/history_screen.dart';
import 'package:device_vital_monitor_flutter_app/presentation/screens/settings/settings_screen.dart';
import 'package:device_vital_monitor_flutter_app/presentation/widgets/common/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _fetchSensorData(BuildContext context) {
    context.read<DashboardBloc>().add(const DashboardSensorDataRequested());
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider(
          create: (_) => getIt<HistoryBloc>()..add(const HistoryRequested()),
          child: const HistoryScreen(),
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SettingsScreen(),
      ),
    );
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
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
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
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
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
          return RefreshIndicator(
            onRefresh: () async => _fetchSensorData(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ThermalStateCard(),
                  const SizedBox(height: 16),
                  const BatteryLevelCard(),
                  const SizedBox(height: 16),
                  const MemoryUsageCard(),
                  const SizedBox(height: 24),
                  const LogStatusButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
