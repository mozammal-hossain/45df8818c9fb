import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/theme/app_colors.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/bloc/dashboard/dashboard_bloc.dart'
    show DashboardBloc, DashboardState, DashboardInitial, DashboardLoading,
        DashboardLoaded, DashboardError;
import 'package:device_vital_monitor_flutter_app/presentation/widgets/cards/vital_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/widgets/common/loading_shimmer.dart';

class ThermalStateCard extends StatelessWidget {
  const ThermalStateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isLoading =
            state is DashboardInitial || state is DashboardLoading;
        if (isLoading) {
          return VitalCard(
            child: Row(
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
                      const LoadingShimmer(height: 24, width: 120),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const LoadingShimmer(height: 40, width: 60),
                          const SizedBox(width: 12),
                          const LoadingShimmer(
                            height: 24,
                            width: 80,
                            borderRadius:
                                BorderRadius.all(Radius.circular(12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const LoadingShimmer(height: 16, width: 180),
                    ],
                  ),
                ),
                const LoadingShimmer(
                  height: 80,
                  width: 80,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
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
        final stateLabel =
            hasData ? _getThermalStateLabel(l10n, stateValue) : l10n.dash;
        final colors = Theme.of(context).extension<AppColors>()!;
        final scheme = Theme.of(context).colorScheme;
        final stateColor = hasData
            ? _getThermalStateColor(context, stateValue)
            : scheme.outline;
        final stateDescription = hasData
            ? _getThermalStateDescription(l10n, stateValue)
            : l10n.thermalDescriptionUnavailable;
        final textTheme = Theme.of(context).textTheme;
        return VitalCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.thermostat, color: stateColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.thermalState, style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$stateValue', style: textTheme.displayLarge),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: stateColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            stateLabel,
                            style: textTheme.labelLarge
                                ?.copyWith(color: colors.onStatus),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(stateDescription, style: textTheme.bodySmall),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
