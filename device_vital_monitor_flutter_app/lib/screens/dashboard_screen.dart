import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../l10n/app_localizations.dart';
import '../widgets/battery_level_card.dart';
import '../widgets/disk_space_card.dart';
import '../widgets/memory_usage_card.dart';
import '../widgets/thermal_state_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _fetchSensorData(BuildContext context) {
    context.read<DashboardBloc>().add(const DashboardSensorDataRequested());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Handle menu tap
          },
        ),
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
            onPressed: () {
              // Handle more options
            },
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          // Trigger initial fetch when screen loads (only once)
          if (state.status == DashboardStatus.initial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchSensorData(context);
            });
          }
          // Handle failure state if needed
          if (state.status == DashboardStatus.failure) {
            // Could show error snackbar here
            debugPrint('Dashboard error: ${state.error}');
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              _fetchSensorData(context);
            },
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
                  const SizedBox(height: 16),
                  const DiskSpaceCard(),
                  const SizedBox(height: 24),
                  _buildLogStatusButton(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogStatusButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ElevatedButton.icon(
      onPressed: () {
        // Handle log status snapshot
      },
      icon: const Icon(Icons.bar_chart),
      label: Text(l10n.logStatusSnapshot),
    );
  }
}
