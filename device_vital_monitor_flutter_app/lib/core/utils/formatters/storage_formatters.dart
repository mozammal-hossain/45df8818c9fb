import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';

/// Utility class for storage-related formatting functions.
class StorageFormatters {
  StorageFormatters._();

  /// Formats bytes to human-readable format (GB, MB, etc.)
  static String formatBytes(AppLocalizations l10n, int bytes) {
    if (bytes < 0) return l10n.zeroBytes;

    final units = [
      l10n.unitB,
      l10n.unitKB,
      l10n.unitMB,
      l10n.unitGB,
      l10n.unitTB,
    ];
    int unitIndex = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    if (unitIndex == 0) {
      return '${size.toInt()} ${units[unitIndex]}';
    } else {
      return '${size.toStringAsFixed(size >= 100 ? 0 : 1)} ${units[unitIndex]}';
    }
  }
}
