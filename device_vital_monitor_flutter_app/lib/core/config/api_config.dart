import 'dart:io';

/// Configuration for the backend API base URL.
/// Uses platform-appropriate default for emulators (Android: 10.0.2.2, iOS: localhost).
class ApiConfig {
  ApiConfig({String? baseUrl})
      : baseUrl = baseUrl ?? _defaultBaseUrl;

  final String baseUrl;

  static String get _defaultBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5265';
    }
    return 'http://localhost:5265';
  }

  String get vitalsPath => '/api/vitals';
  String get vitalsAnalyticsPath => '/api/vitals/analytics';
}
