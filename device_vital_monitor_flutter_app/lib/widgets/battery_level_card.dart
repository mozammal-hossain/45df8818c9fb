import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard/dashboard_bloc.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../utils/battery_formatters.dart';
import '../utils/status_colors.dart';
import 'vital_card.dart';

/// Card widget displaying battery level and related information.
class BatteryLevelCard extends StatelessWidget {
  const BatteryLevelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isLoading = state.status == DashboardStatus.loading ||
            state.status == DashboardStatus.initial;

        final l10n = AppLocalizations.of(context)!;
        final batteryLevel = state.batteryLevel;
        final batteryHealth = state.batteryHealth;
        final chargerConnection = state.chargerConnection;
        final batteryStatus = state.batteryStatus;
        final level = batteryLevel ?? 0;
        final status = batteryLevel != null
            ? BatteryFormatters.getBatteryStatus(l10n, level)
            : l10n.batteryStatusLoading;
        final colors = Theme.of(context).extension<AppColors>()!;
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final statusColor = batteryLevel != null
            ? StatusColors.getBatteryStatusColor(context, level)
            : scheme.outline;

        return VitalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.battery_charging_full,
                  color: scheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(l10n.batteryLevel, style: textTheme.titleLarge),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: textTheme.labelLarge?.copyWith(
                              color: colors.onStatus,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isLoading)
                      const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        '${batteryLevel ?? 0}%',
                        style: textTheme.displayLarge,
                      ),
                    if (batteryLevel != null && !isLoading) ...[
                      const SizedBox(height: 4),
                      Text(
                        BatteryFormatters.getEstimatedTimeRemaining(
                          l10n,
                          level,
                        ),
                        style: textTheme.bodySmall,
                      ),
                    ],
                    if (!isLoading && batteryHealth != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.deviceHealthLabel(
                          BatteryFormatters.formatBatteryHealth(
                            l10n,
                            batteryHealth,
                          ),
                        ),
                        style: textTheme.bodySmall,
                      ),
                    ],
                    if (!isLoading && chargerConnection != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.chargerLabel(
                          BatteryFormatters.formatChargerConnection(
                            l10n,
                            chargerConnection,
                          ),
                        ),
                        style: textTheme.bodySmall,
                      ),
                    ],
                    if (!isLoading && batteryStatus != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.statusLabel(
                          BatteryFormatters.formatBatteryStatus(
                            l10n,
                            batteryStatus,
                          ),
                        ),
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (batteryLevel != null && !isLoading) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: level / 100,
                minHeight: 8,
                backgroundColor: colors.progressTrack,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
          ],
        ],
      ),
    );
      },
    );
  }
}
