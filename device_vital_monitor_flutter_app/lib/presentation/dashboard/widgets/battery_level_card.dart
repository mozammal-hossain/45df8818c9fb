import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/core/theme/app_colors.dart';
import 'package:device_vital_monitor_flutter_app/core/utils/formatters/battery_formatters.dart';
import 'package:device_vital_monitor_flutter_app/core/utils/formatters/status_colors.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/common/widgets/loading_shimmer.dart';
import 'package:device_vital_monitor_flutter_app/presentation/common/widgets/vital_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/dashboard/bloc/dashboard_bloc.dart'
    show
        DashboardBloc,
        DashboardState,
        DashboardInitial,
        DashboardLoading,
        DashboardLoaded,
        DashboardError;

class BatteryLevelCard extends StatelessWidget {
  const BatteryLevelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isLoading =
            state is DashboardInitial || state is DashboardLoading;
        if (isLoading) {
          final ic = AppInsets.iconContainer(context);
          final r = AppInsets.radiusM(context);
          final sS = AppInsets.spacingS(context);
          final sM = AppInsets.spacingM(context);
          return VitalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LoadingShimmer(
                      height: ic,
                      width: ic,
                      borderRadius: BorderRadius.all(Radius.circular(r)),
                    ),
                    SizedBox(width: sM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: sS,
                            runSpacing: sS,
                            children: [
                              LoadingShimmer(height: 24, width: 100),
                              LoadingShimmer(
                                height: 24,
                                width: 60,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(r),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppInsets.spacingSM(context)),
                          LoadingShimmer(height: 48, width: 80),
                          SizedBox(height: sS),
                          LoadingShimmer(height: 14, width: double.infinity),
                          SizedBox(height: AppInsets.spacingXS(context)),
                          LoadingShimmer(height: 14, width: double.infinity),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sM),
                LoadingShimmer(
                  height: AppInsets.progressHeight(context),
                  width: double.infinity,
                ),
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
        final sS = AppInsets.spacingS(context);
        final sM = AppInsets.spacingM(context);
        final sX = AppInsets.spacingXS(context);
        final r = AppInsets.radiusM(context);
        final iconSize = AppInsets.iconM(context);
        final ph = AppInsets.progressHeight(context);
        return VitalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(r),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(r),
                    ),
                    child: Icon(
                      Icons.battery_charging_full,
                      color: scheme.primary,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: sM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: sS,
                          runSpacing: sS,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              l10n.batteryLevel,
                              style: textTheme.titleLarge,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sS,
                                vertical: sX,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(r),
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
                        SizedBox(height: sS),
                        Text('$level%', style: textTheme.displayLarge),
                        if (batteryLevel != null) ...[
                          SizedBox(height: sX),
                          Text(
                            BatteryFormatters.getEstimatedTimeRemaining(
                              l10n,
                              level,
                            ),
                            style: textTheme.bodySmall,
                          ),
                        ],
                        if (batteryHealth != null) ...[
                          SizedBox(height: sX),
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
                          SizedBox(height: sX),
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
                          SizedBox(height: sX),
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
                SizedBox(height: sM),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppInsets.radiusS(context),
                  ),
                  child: LinearProgressIndicator(
                    value: level / 100,
                    minHeight: ph,
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
