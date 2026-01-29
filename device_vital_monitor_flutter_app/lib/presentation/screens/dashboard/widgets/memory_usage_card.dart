import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/core/theme/app_colors.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/bloc/dashboard/dashboard_bloc.dart'
    show DashboardBloc, DashboardState, DashboardInitial, DashboardLoading,
        DashboardLoaded, DashboardError;
import 'package:device_vital_monitor_flutter_app/presentation/widgets/cards/vital_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/widgets/common/loading_shimmer.dart';
import 'package:device_vital_monitor_flutter_app/core/utils/formatters/memory_formatters.dart';
import 'package:device_vital_monitor_flutter_app/core/utils/formatters/status_colors.dart';

class MemoryUsageCard extends StatelessWidget {
  const MemoryUsageCard({super.key});

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
          final sX = AppInsets.spacingXS(context);
          final sSM = AppInsets.spacingSM(context);
          final ch = AppInsets.chartSize(context);
          return VitalCard(
            child: Row(
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
                      LoadingShimmer(height: 24, width: 120),
                      SizedBox(height: sX),
                      LoadingShimmer(height: 14, width: 80),
                      SizedBox(height: sSM),
                      Wrap(
                        spacing: sS,
                        runSpacing: sS,
                        children: [
                          LoadingShimmer(height: 32, width: 60),
                          LoadingShimmer(height: 14, width: 40),
                        ],
                      ),
                    ],
                  ),
                ),
                LoadingShimmer(
                  height: ch,
                  width: ch,
                  shape: BoxShape.circle,
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
        final memoryUsage = data?.memoryUsage;
        final percent = memoryUsage ?? 0;
        final hasData = memoryUsage != null;
        final statusLabel = hasData
            ? MemoryFormatters.getMemoryStatusLabel(l10n, percent)
            : l10n.dash;
        final colors = Theme.of(context).extension<AppColors>()!;
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final statusColor = hasData
            ? StatusColors.getMemoryStatusColor(context, percent)
            : scheme.outline;
        final r = AppInsets.radiusM(context);
        final sS = AppInsets.spacingS(context);
        final sM = AppInsets.spacingM(context);
        final sX = AppInsets.spacingXS(context);
        final ch = AppInsets.chartSize(context);
        final iconSize = AppInsets.iconM(context);
        return VitalCard(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(r),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(r),
                ),
                child: Icon(
                  Icons.memory,
                  color: scheme.primary,
                  size: iconSize,
                ),
              ),
              SizedBox(width: sM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.memoryUsage, style: textTheme.titleLarge),
                    SizedBox(height: sX),
                    Text(statusLabel, style: textTheme.bodySmall),
                    SizedBox(height: sS),
                    Wrap(
                      spacing: sS,
                      runSpacing: sS,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('$percent%', style: textTheme.displayMedium),
                        Text(l10n.used, style: textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: ch,
                height: ch,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: ch,
                      height: ch,
                      child: CircularProgressIndicator(
                        value:
                            hasData ? (percent / 100).clamp(0.0, 1.0) : null,
                        strokeWidth: 8,
                        backgroundColor: colors.progressTrack,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                    Text(
                      hasData ? '$percent%' : l10n.dash,
                      style: textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
