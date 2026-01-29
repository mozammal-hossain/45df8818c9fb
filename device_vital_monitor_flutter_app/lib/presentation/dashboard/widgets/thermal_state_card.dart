import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/layout/app_insets.dart';
import 'package:device_vital_monitor_flutter_app/core/theme/app_colors.dart';
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

class ThermalStateCard extends StatelessWidget {
  const ThermalStateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isLoading =
            state is DashboardInitial || state is DashboardLoading;
        if (isLoading) {
          final ic = AppInsets.iconContainer(context);
          final ch = AppInsets.chartSize(context);
          final r = AppInsets.radiusM(context);
          final rS = AppInsets.radiusS(context);
          final sS = AppInsets.spacingS(context);
          final sM = AppInsets.spacingM(context);
          final sSM = AppInsets.spacingSM(context);
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
                      SizedBox(height: sSM),
                      Wrap(
                        spacing: sSM,
                        runSpacing: sS,
                        children: [
                          LoadingShimmer(height: 40, width: 60),
                          LoadingShimmer(
                            height: 24,
                            width: 80,
                            borderRadius: BorderRadius.all(Radius.circular(r)),
                          ),
                        ],
                      ),
                      SizedBox(height: sS),
                      LoadingShimmer(height: 16, width: double.infinity),
                    ],
                  ),
                ),
                LoadingShimmer(
                  height: ch,
                  width: ch,
                  borderRadius: BorderRadius.circular(rS),
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
        final thermalState = data?.thermalState;
        final stateValue = thermalState ?? 0;
        final hasData = thermalState != null;
        final stateLabel = hasData
            ? _getThermalStateLabel(l10n, stateValue)
            : l10n.dash;
        final colors = Theme.of(context).extension<AppColors>()!;
        final scheme = Theme.of(context).colorScheme;
        final stateColor = hasData
            ? _getThermalStateColor(context, stateValue)
            : scheme.outline;
        final stateDescription = hasData
            ? _getThermalStateDescription(l10n, stateValue)
            : l10n.thermalDescriptionUnavailable;
        final textTheme = Theme.of(context).textTheme;
        final r = AppInsets.radiusM(context);
        final rS = AppInsets.radiusS(context);
        final sS = AppInsets.spacingS(context);
        final sM = AppInsets.spacingM(context);
        final sSM = AppInsets.spacingSM(context);
        final sX = AppInsets.spacingXS(context);
        final ch = AppInsets.chartSize(context);
        final iconSize = AppInsets.iconM(context);
        return VitalCard(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(r),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(r),
                ),
                child: Icon(
                  Icons.thermostat,
                  color: stateColor,
                  size: iconSize,
                ),
              ),
              SizedBox(width: sM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.thermalState, style: textTheme.titleLarge),
                    SizedBox(height: sS),
                    Wrap(
                      spacing: sSM,
                      runSpacing: sS,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('$stateValue', style: textTheme.displayLarge),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sS,
                            vertical: sX,
                          ),
                          decoration: BoxDecoration(
                            color: stateColor,
                            borderRadius: BorderRadius.circular(r),
                          ),
                          child: Text(
                            stateLabel,
                            style: textTheme.labelLarge?.copyWith(
                              color: colors.onStatus,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sX),
                    Text(stateDescription, style: textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                width: ch,
                height: ch,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(rS),
                  gradient: LinearGradient(
                    colors: [
                      stateColor.withValues(alpha: 0.3),
                      stateColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getThermalStateLabel(AppLocalizations l10n, int state) {
    switch (state) {
      case 0:
        return l10n.thermalStateNone;
      case 1:
        return l10n.thermalStateLight;
      case 2:
        return l10n.thermalStateModerate;
      case 3:
        return l10n.thermalStateSevere;
      default:
        return l10n.thermalStateUnknown;
    }
  }

  String _getThermalStateDescription(AppLocalizations l10n, int state) {
    switch (state) {
      case 0:
        return l10n.thermalDescriptionNone;
      case 1:
        return l10n.thermalDescriptionLight;
      case 2:
        return l10n.thermalDescriptionModerate;
      case 3:
        return l10n.thermalDescriptionSevere;
      default:
        return l10n.thermalDescriptionUnavailable;
    }
  }

  Color _getThermalStateColor(BuildContext context, int state) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final scheme = Theme.of(context).colorScheme;
    switch (state) {
      case 0:
        return colors.success;
      case 1:
        return colors.warning;
      case 2:
        return colors.low;
      case 3:
        return colors.error;
      default:
        return scheme.outline;
    }
  }
}
