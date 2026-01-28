// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Device Vital Monitor';

  @override
  String get toggleThemeTooltip => 'Toggle light / dark / system theme';

  @override
  String get thermalState => 'Thermal State';

  @override
  String get thermalStateNone => 'NONE';

  @override
  String get thermalStateLight => 'LIGHT';

  @override
  String get thermalStateModerate => 'MODERATE';

  @override
  String get thermalStateSevere => 'SEVERE';

  @override
  String get thermalStateUnknown => 'UNKNOWN';

  @override
  String get thermalDescriptionNone =>
      'System operating within normal temperature ranges.';

  @override
  String get thermalDescriptionLight =>
      'Slightly elevated temperature, monitoring recommended.';

  @override
  String get thermalDescriptionModerate =>
      'Moderate thermal stress detected. Consider reducing usage.';

  @override
  String get thermalDescriptionSevere =>
      'Severe thermal condition. Device may throttle performance.';

  @override
  String get thermalDescriptionUnavailable => 'Thermal state unavailable.';

  @override
  String get loadingThermalState => 'Loading thermal state...';

  @override
  String get batteryLevel => 'Battery Level';

  @override
  String get batteryStatusHealthy => 'HEALTHY';

  @override
  String get batteryStatusModerate => 'MODERATE';

  @override
  String get batteryStatusLow => 'LOW';

  @override
  String get batteryStatusCritical => 'CRITICAL';

  @override
  String get batteryStatusLoading => 'LOADING';

  @override
  String estimatedTimeRemaining(int hours) {
    return 'Estimated ${hours}h remaining';
  }

  @override
  String deviceHealthLabel(String health) {
    return 'Device health: $health';
  }

  @override
  String chargerLabel(String connection) {
    return 'Charger: $connection';
  }

  @override
  String statusLabel(String status) {
    return 'Status: $status';
  }

  @override
  String get batteryHealthGood => 'Good';

  @override
  String get batteryHealthOverheat => 'Overheat';

  @override
  String get batteryHealthDead => 'Dead';

  @override
  String get batteryHealthOverVoltage => 'Over voltage';

  @override
  String get batteryHealthUnspecifiedFailure => 'Unspecified failure';

  @override
  String get batteryHealthCold => 'Cold';

  @override
  String get chargerAc => 'AC Charger';

  @override
  String get chargerUsb => 'USB';

  @override
  String get chargerWireless => 'Wireless';

  @override
  String get chargerNone => 'Not connected';

  @override
  String get batteryCharging => 'Charging';

  @override
  String get batteryDischarging => 'Discharging';

  @override
  String get batteryFull => 'Full';

  @override
  String get batteryNotCharging => 'Not charging';

  @override
  String get batteryUnknown => 'Unknown';

  @override
  String get memoryUsage => 'Memory Usage';

  @override
  String get memoryCritical => 'Critical';

  @override
  String get memoryHigh => 'High';

  @override
  String get memoryModerate => 'Moderate';

  @override
  String get memoryNormal => 'Normal';

  @override
  String get memoryOptimized => 'Optimized';

  @override
  String get used => 'used';

  @override
  String get loading => 'loading…';

  @override
  String get unavailable => 'unavailable';

  @override
  String get dash => '—';

  @override
  String get diskSpace => 'Disk Space';

  @override
  String get total => 'total';

  @override
  String usedFormatted(String formatted) {
    return 'Used: $formatted';
  }

  @override
  String availableFormatted(String formatted) {
    return 'Available: $formatted';
  }

  @override
  String get storageUnavailable => 'Storage information unavailable';

  @override
  String get logStatusSnapshot => 'Log Status Snapshot';

  @override
  String get unitB => 'B';

  @override
  String get unitKB => 'KB';

  @override
  String get unitMB => 'MB';

  @override
  String get unitGB => 'GB';

  @override
  String get unitTB => 'TB';

  @override
  String get zeroBytes => '0 B';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty =>
      'No vitals logged yet. Use “Log Status” on the dashboard.';

  @override
  String get analyticsTitle => 'Analytics (rolling window)';

  @override
  String get averageThermalLabel => 'Avg thermal';

  @override
  String get averageBatteryLabel => 'Avg battery';

  @override
  String get averageMemoryLabel => 'Avg memory';

  @override
  String get totalLogsLabel => 'Total logs';

  @override
  String get rollingWindowLogsLabel => 'Logs in window';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get loggingEllipsis => 'Logging…';

  @override
  String get appSettingsTitle => 'App Settings';

  @override
  String get settingsSubtitle => 'Manage your preferences';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageBangla => 'Bangla';

  @override
  String get languageEnglish => 'English';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystemDefault => 'System Default';

  @override
  String get settingsTitle => 'Settings';

  @override
  String versionBuild(String version, String build) {
    return 'Version $version (Build $build)';
  }
}
