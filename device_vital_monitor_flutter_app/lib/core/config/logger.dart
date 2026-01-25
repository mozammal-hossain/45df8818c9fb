import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Singleton class for application logging using PrettyDioLogger
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  late PrettyDioLogger _logger;

  // Configuration storage
  bool _requestHeader = true;
  bool _requestBody = true;
  bool _responseBody = true;
  bool _responseHeader = false;
  bool _error = true;
  bool _compact = true;
  int _maxWidth = 90;

  // Enable/disable general logging
  bool _enableLogging = true;

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal() {
    _createLogger();
  }

  void _createLogger() {
    _logger = PrettyDioLogger(
      requestHeader: _requestHeader,
      requestBody: _requestBody,
      responseBody: _responseBody,
      responseHeader: _responseHeader,
      error: _error,
      compact: _compact,
      maxWidth: _maxWidth,
    );
  }

  /// Get the PrettyDioLogger instance
  PrettyDioLogger get logger => _logger;

  /// Update logger configuration
  void updateConfig({
    bool? requestHeader,
    bool? requestBody,
    bool? responseBody,
    bool? responseHeader,
    bool? error,
    bool? compact,
    int? maxWidth,
    bool? enableLogging,
  }) {
    if (requestHeader != null) _requestHeader = requestHeader;
    if (requestBody != null) _requestBody = requestBody;
    if (responseBody != null) _responseBody = responseBody;
    if (responseHeader != null) _responseHeader = responseHeader;
    if (error != null) _error = error;
    if (compact != null) _compact = compact;
    if (maxWidth != null) _maxWidth = maxWidth;
    if (enableLogging != null) _enableLogging = enableLogging;

    // Recreate logger with new configuration
    _createLogger();
  }

  /// Log an error message
  /// 
  /// [message] - The error message to log
  /// [error] - Optional error object or exception
  /// [stackTrace] - Optional stack trace
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final errorPrefix = '❌ [ERROR]';
    
    debugPrint('$errorPrefix [$timestamp] $message');
    
    if (error != null) {
      debugPrint('$errorPrefix Error details: $error');
    }
    
    if (stackTrace != null) {
      debugPrint('$errorPrefix Stack trace: $stackTrace');
    }
  }

  /// Log a success message
  /// 
  /// [message] - The success message to log
  void success(String message) {
    if (!_enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final successPrefix = '✅ [SUCCESS]';
    
    debugPrint('$successPrefix [$timestamp] $message');
  }

  /// Log an info message
  /// 
  /// [message] - The info message to log
  void info(String message) {
    if (!_enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final infoPrefix = 'ℹ️  [INFO]';
    
    debugPrint('$infoPrefix [$timestamp] $message');
  }

  /// Log a debug message
  /// 
  /// [message] - The debug message to log
  /// [data] - Optional additional data to log
  void debug(String message, {Object? data}) {
    if (!_enableLogging) return;

    final timestamp = DateTime.now().toIso8601String();
    final debugPrefix = '🔍 [DEBUG]';
    
    debugPrint('$debugPrefix [$timestamp] $message');
    
    if (data != null) {
      debugPrint('$debugPrefix Data: $data');
    }
  }

  /// Enable or disable general logging
  void setLoggingEnabled(bool enabled) {
    _enableLogging = enabled;
  }
}
