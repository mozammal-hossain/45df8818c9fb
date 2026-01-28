import 'package:flutter/foundation.dart';

/// Application logger. Wraps debugPrint with optional prefixes.
abstract final class Logger {
  Logger._();

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('❌ [ERROR] $message');
      if (error != null) debugPrint('  $error');
      if (stackTrace != null) debugPrint('  $stackTrace');
    }
  }

  static void info(String message) {
    if (kDebugMode) debugPrint('ℹ️ [INFO] $message');
  }

  static void debug(String message, [Object? data]) {
    if (kDebugMode) {
      debugPrint('🔍 [DEBUG] $message');
      if (data != null) debugPrint('  $data');
    }
  }
}
