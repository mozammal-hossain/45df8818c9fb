import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/core/platform/method_channels.dart';

@lazySingleton
class AutoLoggingPlatformDatasource {
  AutoLoggingPlatformDatasource() {
    _channel = const MethodChannel(AutoLoggingChannel.name);
  }

  late final MethodChannel _channel;

  /// Schedules background auto-logging (WorkManager on Android, BGAppRefresh on iOS).
  /// [baseUrl] and [deviceId] are stored on the native side for the background task.
  Future<void> scheduleBackgroundAutoLog({
    required String baseUrl,
    required String deviceId,
  }) async {
    try {
      await _channel.invokeMethod<void>(
        AutoLoggingChannel.scheduleBackground,
        <String, String>{'baseUrl': baseUrl, 'deviceId': deviceId},
      );
    } on PlatformException catch (e) {
      debugPrint(
        'AutoLoggingPlatformDatasource.scheduleBackgroundAutoLog: ${e.code} ${e.message}',
      );
    } on MissingPluginException {
      debugPrint(
        'AutoLoggingPlatformDatasource.scheduleBackgroundAutoLog: plugin not implemented',
      );
    }
  }

  /// Cancels background auto-logging.
  Future<void> cancelBackgroundAutoLog() async {
    try {
      await _channel.invokeMethod<void>(AutoLoggingChannel.cancelBackground);
    } on PlatformException catch (e) {
      debugPrint(
        'AutoLoggingPlatformDatasource.cancelBackgroundAutoLog: ${e.code} ${e.message}',
      );
    } on MissingPluginException {
      debugPrint(
        'AutoLoggingPlatformDatasource.cancelBackgroundAutoLog: plugin not implemented',
      );
    }
  }
}
