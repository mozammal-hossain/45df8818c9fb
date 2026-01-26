import '../l10n/app_localizations.dart';

/// Utility class for battery-related formatting functions.
class BatteryFormatters {
  BatteryFormatters._();

  static String getBatteryStatus(AppLocalizations l10n, int level) {
    if (level >= 80) return l10n.batteryStatusHealthy;
    if (level >= 50) return l10n.batteryStatusModerate;
    if (level >= 20) return l10n.batteryStatusLow;
    return l10n.batteryStatusCritical;
  }

  static String getEstimatedTimeRemaining(AppLocalizations l10n, int level) {
    final hours = (level * 0.14).round();
    return l10n.estimatedTimeRemaining(hours);
  }

  static String formatBatteryHealth(AppLocalizations l10n, String health) {
    switch (health) {
      case 'GOOD':
        return l10n.batteryHealthGood;
      case 'OVERHEAT':
        return l10n.batteryHealthOverheat;
      case 'DEAD':
        return l10n.batteryHealthDead;
      case 'OVER_VOLTAGE':
        return l10n.batteryHealthOverVoltage;
      case 'UNSPECIFIED_FAILURE':
        return l10n.batteryHealthUnspecifiedFailure;
      case 'COLD':
        return l10n.batteryHealthCold;
      default:
        return health;
    }
  }

  static String formatChargerConnection(
    AppLocalizations l10n,
    String connection,
  ) {
    switch (connection) {
      case 'AC':
        return l10n.chargerAc;
      case 'USB':
        return l10n.chargerUsb;
      case 'WIRELESS':
        return l10n.chargerWireless;
      case 'NONE':
        return l10n.chargerNone;
      default:
        return connection;
    }
  }

  static String formatBatteryStatus(AppLocalizations l10n, String status) {
    switch (status) {
      case 'CHARGING':
        return l10n.batteryCharging;
      case 'DISCHARGING':
        return l10n.batteryDischarging;
      case 'FULL':
        return l10n.batteryFull;
      case 'NOT_CHARGING':
        return l10n.batteryNotCharging;
      case 'UNKNOWN':
        return l10n.batteryUnknown;
      default:
        return status;
    }
  }
}
