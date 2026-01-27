import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dashboard/dashboard_bloc.dart';
import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../utils/memory_formatters.dart';
import '../utils/status_colors.dart';
import 'loading_shimmer.dart';
import 'vital_card.dart';

/// Card widget displaying memory usage information.
class MemoryUsageCard extends StatelessWidget {
  const MemoryUsageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final isLoading =
            state.status == DashboardStatus.loading ||
            state.status == DashboardStatus.initial;

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
                      const SizedBox(height: 4),
                      const LoadingShimmer(height: 14, width: 80),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          const LoadingShimmer(height: 32, width: 60),
                          const SizedBox(width: 8),
                          const LoadingShimmer(height: 14, width: 40),
                        ],
                      ),
                    ],
                  ),
                ),
                const LoadingShimmer(
                  height: 80,
                  width: 80,
                  shape: BoxShape.circle,
                ),
              ],
            ),
          );
        }

        final l10n = AppLocalizations.of(context)!;
        final memoryUsage = state.memoryUsage;
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

        return VitalCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.memory, color: scheme.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.memoryUsage, style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(statusLabel, style: textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('$percent%', style: textTheme.displayMedium),
                        const SizedBox(width: 8),
                        Text(l10n.used, style: textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: hasData ? (percent / 100).clamp(0.0, 1.0) : null,
                        strokeWidth: 8,
                        backgroundColor: colors.progressTrack,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
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
