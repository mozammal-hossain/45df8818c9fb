import 'package:flutter/material.dart';

import 'package:device_vital_monitor_flutter_app/domain/entities/analytics_result.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/widgets/cards/vital_card.dart';

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({super.key, required this.analytics});

  final AnalyticsResult analytics;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    return VitalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.analyticsTitle, style: textTheme.titleMedium),
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
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
