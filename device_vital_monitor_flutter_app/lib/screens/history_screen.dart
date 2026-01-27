import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/history/history_bloc.dart';
import '../l10n/app_localizations.dart';
import '../models/analytics_result.dart';
import '../models/vital_log.dart';
import '../widgets/vital_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text(l10n.historyTitle),
      ),
      body: BlocConsumer<HistoryBloc, HistoryState>(
        listener: (context, state) {
          if (state.status == HistoryStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: scheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == HistoryStatus.initial ||
              state.status == HistoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == HistoryStatus.failure && state.logs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: scheme.error),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage ?? 'Could not load history.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HistoryBloc>().add(const HistoryRequested());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state.analytics != null) ...[
                    _AnalyticsCard(analytics: state.analytics!),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    l10n.historyTitle,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (state.logs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        l10n.historyEmpty,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ...state.logs.map((log) => _HistoryTile(log: log)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.analytics});

  final AnalyticsResult analytics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return VitalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.analyticsTitle,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetricChip(
                label: l10n.averageThermalLabel,
                value: analytics.averageThermal.toStringAsFixed(1),
              ),
              const SizedBox(width: 8),
              _MetricChip(
                label: l10n.averageBatteryLabel,
                value: '${analytics.averageBattery.toStringAsFixed(0)}%',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MetricChip(
                label: l10n.averageMemoryLabel,
                value: '${analytics.averageMemory.toStringAsFixed(0)}%',
              ),
              const SizedBox(width: 8),
              _MetricChip(
                label: l10n.totalLogsLabel,
                value: '${analytics.totalLogs}',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.rollingWindowLogsLabel}: ${analytics.rollingWindowLogs}',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.log});

  final VitalLog log;

  static final _timeFormat = DateFormat('MMM d, HH:mm');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final time =
        log.timestamp.isUtc ? log.timestamp : log.timestamp.toUtc();
    final timeStr = _timeFormat.format(time.toLocal());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(timeStr, style: textTheme.titleSmall),
        subtitle: Text(
          'Thermal: ${log.thermalValue} · Battery: ${log.batteryLevel.toStringAsFixed(0)}% · Memory: ${log.memoryUsage.toStringAsFixed(0)}%',
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
