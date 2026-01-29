import 'package:flutter/material.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/core/theme/app_colors.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/analytics_result.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/common/widgets/vital_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/history/widgets/thermal_sparkline.dart';

class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({
    super.key,
    required this.analytics,
    this.thermalSparklineValues = const [],
  });

  final AnalyticsResult analytics;

  /// Thermal values 0–1 (newest first) for the sparkline; e.g. from recent logs.
  final List<double> thermalSparklineValues;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    final sSM = AppInsets.spacingSM(context);
    final sS = AppInsets.spacingS(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.analyticsTitle,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: sS),
        Text(
          l10n.analyticsSubtitleRolling24h,
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        SizedBox(height: sSM),
        VitalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.thermalLabelShort,
                          style: textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: sS),
                        Text(
                          analytics.averageThermal.toStringAsFixed(1),
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _TrendBadge(trend: analytics.trendThermal),
                ],
              ),
              if (thermalSparklineValues.isNotEmpty) ...[
                SizedBox(height: sSM),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: ThermalSparklinePainter(
                      values: thermalSparklineValues,
                      lineColor: colors.iconTint.withValues(alpha: 0.8),
                      fillColor: scheme.primaryContainer.withValues(alpha: 0.3),
                    ),
                    size: Size.infinite,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: sS),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: l10n.batteryLabelShort,
                value: '${analytics.averageBattery.toStringAsFixed(0)}%',
                trend: analytics.trendBattery,
              ),
            ),
            SizedBox(width: sS),
            Expanded(
              child: _MetricCard(
                label: l10n.memoryLabelShort,
                value: '${analytics.averageMemory.toStringAsFixed(0)}%',
                trend: analytics.trendMemory,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.trend});

  final String trend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<AppColors>()!;

    final isDecreasing = trend == 'decreasing';
    final isIncreasing = trend == 'increasing';
    final isStable = trend == 'stable';
    final color = isDecreasing
        ? colors.error
        : isIncreasing
        ? colors.success
        : scheme.onSurfaceVariant;

    String label;
    IconData icon;
    if (isDecreasing) {
      label = '-2%';
      icon = Icons.trending_down;
    } else if (isIncreasing) {
      label = '+6%';
      icon = Icons.trending_up;
    } else if (isStable) {
      label = '0%';
      icon = Icons.trending_flat;
    } else {
      label = '—';
      icon = Icons.remove;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.trend,
  });

  final String label;
  final String value;
  final String trend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<AppColors>()!;

    final isDecreasing = trend == 'decreasing';
    final isIncreasing = trend == 'increasing';
    final color = isDecreasing
        ? colors.error
        : (isIncreasing ? colors.success : scheme.onSurfaceVariant);
    final icon = isDecreasing
        ? Icons.trending_down
        : (isIncreasing ? Icons.trending_up : Icons.trending_flat);
    final trendLabel = isDecreasing ? '-1%' : (isIncreasing ? '+5%' : '0%');

    return VitalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppInsets.spacingXS(context)),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                trendLabel,
                style: textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
