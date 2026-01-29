import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/core/theme/app_colors.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';

/// Status derived from a vital log for display (badge and coloring).
enum VitalLogStatus { optimal, normal, space, critical }

VitalLogStatus vitalLogStatusFromLog(VitalLog log) {
  if (log.batteryLevel < 20 || log.thermalValue >= 3)
    return VitalLogStatus.critical;
  if (log.thermalValue >= 2 || log.batteryLevel < 40 || log.memoryUsage > 85) {
    return VitalLogStatus.space;
  }
  if (log.thermalValue >= 1 || log.batteryLevel < 60 || log.memoryUsage > 70) {
    return VitalLogStatus.normal;
  }
  return VitalLogStatus.optimal;
}

/// Thermal 0–3 displayed as 0–1 scale with one decimal.
String formatThermalForDisplay(int thermalValue) =>
    (thermalValue / 3.0).toStringAsFixed(1);

class VitalLogItem extends StatelessWidget {
  const VitalLogItem({super.key, required this.log});

  final VitalLog log;

  static final _timeFormat = DateFormat.jm();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).extension<AppColors>()!;
    final localTime = log.timestamp.isUtc
        ? log.timestamp.toLocal()
        : log.timestamp;
    final timeStr = _timeFormat.format(localTime);
    final status = vitalLogStatusFromLog(log);
    final gap = AppInsets.spacingS(context);
    final r = AppInsets.radiusS(context);
    final padding = AppInsets.cardPadding(context);

    final statusLabel = switch (status) {
      VitalLogStatus.optimal => l10n.statusOptimal,
      VitalLogStatus.normal => l10n.statusNormal,
      VitalLogStatus.space => l10n.statusSpace,
      VitalLogStatus.critical => l10n.statusCritical,
    };
    final (statusBg, statusFg) = _statusColors(status, colors, scheme);

    final thermalStr = formatThermalForDisplay(log.thermalValue);
    final batteryStr = '${log.batteryLevel.toStringAsFixed(0)}%';
    final memoryStr = '${log.memoryUsage.toStringAsFixed(0)}%';

    final thermalColor = _thermalValueColor(log.thermalValue, colors, scheme);
    final batteryColor = _batteryValueColor(log.batteryLevel, colors, scheme);
    final memoryColor = _memoryValueColor(log.memoryUsage, colors, scheme);

    return Container(
      margin: EdgeInsets.only(bottom: gap),
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 18,
                color: scheme.primary.withValues(alpha: 0.9),
              ),
              SizedBox(width: AppInsets.spacingXS(context)),
              Text(
                timeStr,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: statusFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: gap),
          Row(
            children: [
              Expanded(
                child: _MetricChip(
                  label: l10n.thermalLabelShort,
                  value: thermalStr,
                  valueColor: thermalColor,
                ),
              ),
              SizedBox(width: AppInsets.spacingXS(context)),
              Expanded(
                child: _MetricChip(
                  label: l10n.batteryLabelShort,
                  value: batteryStr,
                  valueColor: batteryColor,
                ),
              ),
              SizedBox(width: AppInsets.spacingXS(context)),
              Expanded(
                child: _MetricChip(
                  label: l10n.memoryLabelShort,
                  value: memoryStr,
                  valueColor: memoryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, Color) _statusColors(
    VitalLogStatus status,
    AppColors colors,
    ColorScheme scheme,
  ) {
    return switch (status) {
      VitalLogStatus.optimal => (
        colors.success.withValues(alpha: 0.2),
        colors.success,
      ),
      VitalLogStatus.normal => (
        colors.success.withValues(alpha: 0.2),
        colors.success,
      ),
      VitalLogStatus.space => (
        colors.warning.withValues(alpha: 0.25),
        colors.warning,
      ),
      VitalLogStatus.critical => (
        colors.error.withValues(alpha: 0.2),
        colors.error,
      ),
    };
  }

  Color _thermalValueColor(int thermal, AppColors colors, ColorScheme scheme) {
    if (thermal >= 3) return colors.error;
    if (thermal >= 2) return colors.warning;
    return scheme.onSurface;
  }

  Color _batteryValueColor(
    double battery,
    AppColors colors,
    ColorScheme scheme,
  ) {
    if (battery < 20) return colors.error;
    if (battery < 40) return colors.warning;
    return scheme.onSurface;
  }

  Color _memoryValueColor(double memory, AppColors colors, ColorScheme scheme) {
    if (memory > 90) return colors.error;
    if (memory > 80) return colors.warning;
    return scheme.onSurface;
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final r = AppInsets.radiusS(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppInsets.spacingSM(context),
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
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
