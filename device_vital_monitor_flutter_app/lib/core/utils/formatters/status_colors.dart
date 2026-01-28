import 'package:flutter/material.dart';

import 'package:device_vital_monitor_flutter_app/core/theme/app_colors.dart';

/// Utility class for determining status colors based on metrics.
class StatusColors {
  StatusColors._();

  static Color getBatteryStatusColor(BuildContext context, int level) {
    final colors = Theme.of(context).extension<AppColors>()!;
    if (level >= 80) return colors.success;
    if (level >= 50) return colors.warning;
    if (level >= 20) return colors.low;
    return colors.error;
  }

  static Color getMemoryStatusColor(BuildContext context, int percent) {
    final colors = Theme.of(context).extension<AppColors>()!;
    if (percent >= 90) return colors.error;
    if (percent >= 75) return colors.low;
    if (percent >= 50) return colors.warning;
    return colors.success;
  }
}
