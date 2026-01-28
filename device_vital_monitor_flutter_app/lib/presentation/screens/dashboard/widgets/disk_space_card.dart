import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:device_vital_monitor_flutter_app/core/theme/app_colors.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/storage_info.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/presentation/bloc/dashboard/dashboard_bloc.dart'
    show DashboardBloc, DashboardState, DashboardInitial, DashboardLoading,
        DashboardLoaded, DashboardError;
import 'package:device_vital_monitor_flutter_app/presentation/widgets/cards/vital_card.dart';
import 'package:device_vital_monitor_flutter_app/presentation/widgets/common/loading_shimmer.dart';
import 'package:device_vital_monitor_flutter_app/core/utils/formatters/memory_formatters.dart';
import 'package:device_vital_monitor_flutter_app/core/utils/formatters/status_colors.dart';
import 'package:device_vital_monitor_flutter_app/core/utils/formatters/storage_formatters.dart';

class DiskSpaceCard extends StatelessWidget {
  const DiskSpaceCard({super.key});

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
                          const LoadingShimmer(height: 24, width: 100),
                          const SizedBox(height: 4),
                          const LoadingShimmer(height: 14, width: 80),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const LoadingShimmer(height: 32, width: 80),
                    const SizedBox(width: 8),
                    const LoadingShimmer(height: 14, width: 40),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const LoadingShimmer(height: 14, width: 120),
                          const SizedBox(height: 4),
                          const LoadingShimmer(height: 14, width: 120),
                        ],
                      ),
                    ),
                    const LoadingShimmer(
                      height: 60,
                      width: 60,
                      shape: BoxShape.circle,
                    ),
                  ],
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
        final StorageInfo? storageInfo = data?.storageInfo;
        final hasData = storageInfo != null;
        final totalBytes = storageInfo?.total ?? 0;
        final usedBytes = storageInfo?.used ?? 0;
        final availableBytes = storageInfo?.available ?? 0;
        final usagePercent = storageInfo?.usagePercent ?? 0;
        final colors = Theme.of(context).extension<AppColors>()!;
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        final statusColor = hasData
            ? StatusColors.getMemoryStatusColor(context, usagePercent)
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
                    child: Icon(Icons.storage, color: scheme.primary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.diskSpace, style: textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          hasData
                              ? MemoryFormatters.getMemoryStatusLabel(
                                  l10n,
                                  usagePercent,
                                )
                              : l10n.dash,
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (hasData) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      StorageFormatters.formatBytes(l10n, totalBytes),
                      style: textTheme.displayMedium,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.total, style: textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.usedFormatted(
                              StorageFormatters.formatBytes(l10n, usedBytes),
                            ),
                            style: textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.availableFormatted(
                              StorageFormatters.formatBytes(
                                l10n,
                                availableBytes,
                              ),
                            ),
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value:
                                  (usagePercent / 100).clamp(0.0, 1.0),
                              strokeWidth: 6,
                              backgroundColor: colors.progressTrack,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                statusColor,
                              ),
                            ),
                          ),
                          Text(
                            '$usagePercent%',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else
                Text(l10n.storageUnavailable, style: textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}
