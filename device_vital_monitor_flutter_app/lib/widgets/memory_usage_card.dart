import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../utils/memory_formatters.dart';
import '../utils/status_colors.dart';
import 'vital_card.dart';

/// Card widget displaying memory usage information.
class MemoryUsageCard extends StatelessWidget {
  const MemoryUsageCard({
    super.key,
    required this.memoryUsage,
    required this.isLoading,
  });

  final int? memoryUsage;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final percent = memoryUsage ?? 0;
    final hasData = memoryUsage != null && !isLoading;
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
                    if (isLoading)
                      const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Text(
                        '${memoryUsage ?? 0}%',
                        style: textTheme.displayMedium,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      hasData
                          ? l10n.used
                          : (isLoading ? l10n.loading : l10n.unavailable),
                      style: textTheme.bodySmall,
                    ),
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
                  hasData ? '$percent%' : (isLoading ? '…' : l10n.dash),
                  style: textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
