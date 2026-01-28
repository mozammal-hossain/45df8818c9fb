import '../utils/constants.dart';

/// Application-level configuration (version, build, branding).
abstract final class AppConfig {
  AppConfig._();

  static String get version => Constants.appVersion;
  static String get build => Constants.appBuild;
  static String get versionBuild =>
      '${Constants.appVersion} (Build ${Constants.appBuild})';
}
