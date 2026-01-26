import '../l10n/app_localizations.dart';

/// Utility class for memory-related formatting functions.
class MemoryFormatters {
  MemoryFormatters._();

  static String getMemoryStatusLabel(AppLocalizations l10n, int percent) {
    if (percent >= 90) return l10n.memoryCritical;
    if (percent >= 75) return l10n.memoryHigh;
    if (percent >= 50) return l10n.memoryModerate;
    if (percent >= 25) return l10n.memoryNormal;
    return l10n.memoryOptimized;
  }
}
