/// Application and preference key constants.
abstract final class Constants {
  Constants._();

  /// App version for display (align with pubspec or package_info_plus).
  static const String appVersion = '1.0.0';

  /// Build number for display.
  static const String appBuild = '1';

  /// SharedPreferences key for theme mode.
  static const String themeModeKey = 'theme_mode';

  /// SharedPreferences key for app locale.
  static const String localeKey = 'app_locale';

  /// SharedPreferences key for persistent device id.
  static const String deviceIdKey = 'device_vital_monitor_device_id';

  /// SharedPreferences key for auto-logging enabled (bool).
  static const String autoLoggingEnabledKey = 'auto_logging_enabled';
}
