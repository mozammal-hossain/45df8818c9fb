import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../core/injection/injection.dart';
import '../l10n/app_localizations.dart';
import '../screens/history_screen.dart';
import '../bloc/history/history_bloc.dart';
import '../widgets/battery_level_card.dart';
import '../widgets/disk_space_card.dart';
import '../widgets/memory_usage_card.dart';
import '../widgets/thermal_state_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _fetchSensorData(BuildContext context) {
    context.read<DashboardBloc>().add(const DashboardSensorDataRequested());
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).pop(); // close drawer
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider(
          create: (_) => getIt<HistoryBloc>()..add(const HistoryRequested()),
          child: const HistoryScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: scheme.primaryContainer),
              child: Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(l10n.dashboardTitle),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(l10n.historyTitle),
              onTap: () => _openHistory(context),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(l10n.appTitle),
        // Drawer adds menu icon automatically
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
          // Listener runs only on state *changes*; initial fetch is triggered from builder below.
          if (state.status == DashboardStatus.failure) {
            debugPrint('Dashboard error: ${state.error}');
          }
          // Log status feedback
          if (state.logStatusState == LogStatusState.success &&
              state.logStatusMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.logStatusMessage!),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            );
          }
          if (state.logStatusState == LogStatusState.failure &&
              state.logStatusMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.logStatusMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          // Trigger initial fetch once. BlocConsumer's listener is not called for the
          // initial state, so we schedule the fetch here when we see initial.
          if (state.status == DashboardStatus.initial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                _fetchSensorData(context);
              }
            });
          }
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
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (a, b) =>
          a.logStatusState != b.logStatusState ||
          a.status != b.status,
      builder: (context, state) {
        final isSubmitting = state.logStatusState == LogStatusState.submitting;
        return FilledButton.icon(
          onPressed: isSubmitting
              ? null
              : () {
                  context
                      .read<DashboardBloc>()
                      .add(const DashboardLogStatusRequested());
                },
          icon: isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.bar_chart),
          label: Text(
            isSubmitting ? l10n.loggingEllipsis : l10n.logStatusSnapshot,
          ),
        );
      },
    );
  }
}
