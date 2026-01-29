import 'package:flutter/material.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
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
    final sS = AppInsets.spacingS(context);
    final sSM = AppInsets.spacingSM(context);
    final sX = AppInsets.spacingXS(context);
    return VitalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.analyticsTitle, style: textTheme.titleMedium),
          SizedBox(height: sSM),
          Wrap(
            spacing: sS,
            runSpacing: sS,
            children: [
              _MetricChip(
                label: l10n.averageThermalLabel,
                value: analytics.averageThermal.toStringAsFixed(1),
              ),
              _MetricChip(
                label: l10n.averageBatteryLabel,
                value: '${analytics.averageBattery.toStringAsFixed(0)}%',
              ),
              _MetricChip(
                label: l10n.averageMemoryLabel,
                value: '${analytics.averageMemory.toStringAsFixed(0)}%',
              ),
              _MetricChip(
                label: l10n.totalLogsLabel,
                value: '${analytics.totalLogs}',
              ),
            ],
          ),
          SizedBox(height: sX),
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
    final r = AppInsets.radiusS(context);
    final sSM = AppInsets.spacingSM(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sSM,
        vertical: AppInsets.spacingXS(context) + 2,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(r),
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
