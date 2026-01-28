import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/theme/app_colors.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/bloc/dashboard/dashboard_bloc.dart'
    show DashboardBloc, DashboardState, DashboardInitial, DashboardLoading,
        DashboardLoaded, DashboardError;
import 'package:device_vital_monitor_flutter_app/presentation/widgets/cards/vital_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/widgets/common/loading_shimmer.dart';
import 'package:device_vital_monitor_flutter_app/core/utils/formatters/battery_formatters.dart';
import 'package:device_vital_monitor_flutter_app/core/utils/formatters/status_colors.dart';

class BatteryLevelCard extends StatelessWidget {
  const BatteryLevelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isLoading =
            state is DashboardInitial || state is DashboardLoading;
        if (isLoading) {
          return VitalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LoadingShimmer(
                      height: 56,
                      width: 56,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const LoadingShimmer(height: 24, width: 100),
                              const SizedBox(width: 8),
                              const LoadingShimmer(
                                height: 24,
                                width: 60,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const LoadingShimmer(height: 48, width: 80),
                          const SizedBox(height: 8),
                          const LoadingShimmer(height: 14, width: 150),
                          const SizedBox(height: 4),
                          const LoadingShimmer(height: 14, width: 120),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const LoadingShimmer(height: 8, width: double.infinity),
              ],
            ),
          );
        }
        final l10n = AppLocalizations.of(context)!;
        final data = switch (state) {
          DashboardLoaded(:final sensorData) => sensorData,
          DashboardError(:final lastKnownData) => lastKnownData,
          _ => null,
        };
        final batteryLevel = data?.batteryLevel;
        final batteryHealth = data?.batteryHealth;
        final chargerConnection = data?.chargerConnection;
        final batteryStatus = data?.batteryStatus;
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
                            Text(
                              l10n.batteryLevel,
                              style: textTheme.titleLarge,
                            ),
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
                                style: textTheme.labelLarge
                                    ?.copyWith(color: colors.onStatus),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('$level%', style: textTheme.displayLarge),
                        if (batteryLevel != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            BatteryFormatters.getEstimatedTimeRemaining(
                              l10n,
                              level,
                            ),
                            style: textTheme.bodySmall,
                          ),
                        ],
                        if (batteryHealth != null) ...[
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
                        if (chargerConnection != null) ...[
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
                        if (batteryStatus != null) ...[
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
              if (batteryLevel != null) ...[
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
