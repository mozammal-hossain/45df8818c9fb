import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for reading device sensors via native MethodChannel.
/// Uses [device_vital_monitor/sensors] channel (Android MainActivity).
class DeviceSensorService {
  DeviceSensorService._();
  static const _channel = MethodChannel('device_vital_monitor/sensors');

  /// Returns battery level 0-100, or null if unavailable / error.
  static Future<int?> getBatteryLevel() async {
    try {
      final level = await _channel.invokeMethod<int>('getBatteryLevel');
      return level;
    } on PlatformException catch (_) {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Returns Android battery health: GOOD, OVERHEAT, DEAD, OVER_VOLTAGE,
  /// UNSPECIFIED_FAILURE, COLD, or UNKNOWN. Null if unavailable / error.
  static Future<String?> getBatteryHealth() async {
    try {
      final result = await _channel.invokeMethod<Object?>('getBatteryHealth');
      if (result == null) return null;
      return result is String ? result : result.toString();
    } on PlatformException catch (e) {
      debugPrint('DeviceSensorService.getBatteryHealth PlatformException: ${e.code} ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Returns charger connection type: AC, USB, WIRELESS, or NONE.
  /// Null if unavailable / error.
  static Future<String?> getChargerConnection() async {
    try {
      final result = await _channel.invokeMethod<Object?>('getChargerConnection');
      if (result == null) return null;
      return result is String ? result : result.toString();
    } on PlatformException catch (e) {
      debugPrint('DeviceSensorService.getChargerConnection PlatformException: ${e.code} ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Returns battery status: CHARGING, DISCHARGING, FULL, NOT_CHARGING, or UNKNOWN.
  /// Null if unavailable / error.
  static Future<String?> getBatteryStatus() async {
    try {
      final result = await _channel.invokeMethod<Object?>('getBatteryStatus');
      if (result == null) return null;
      return result is String ? result : result.toString();
    } on PlatformException catch (e) {
      debugPrint('DeviceSensorService.getBatteryStatus PlatformException: ${e.code} ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
