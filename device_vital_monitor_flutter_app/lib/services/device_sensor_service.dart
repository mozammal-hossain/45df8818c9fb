import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for reading device sensors via native MethodChannel.
/// Uses [device_vital_monitor/sensors] channel (Android MainActivity).
class DeviceSensorService {
  DeviceSensorService._();
  static const _channel = MethodChannel('device_vital_monitor/sensors');

  /// Returns thermal state 0-3, or null if unavailable / error.
  /// 0 = NONE, 1 = LIGHT, 2 = MODERATE, 3 = SEVERE
  static Future<int?> getThermalState() async {
    try {
      final state = await _channel.invokeMethod<int>('getThermalState');
      return state;
    } on PlatformException catch (e) {
      debugPrint('DeviceSensorService.getThermalState PlatformException: ${e.code} ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

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

  /// Returns memory usage as percentage 0–100 (system-wide on Android, process vs total on iOS).
  /// Null if unavailable / error.
  static Future<int?> getMemoryUsage() async {
    try {
      final level = await _channel.invokeMethod<int>('getMemoryUsage');
      return level;
    } on PlatformException catch (e) {
      debugPrint('DeviceSensorService.getMemoryUsage PlatformException: ${e.code} ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Storage information model
  static const String _storageTotalKey = 'total';
  static const String _storageUsedKey = 'used';
  static const String _storageAvailableKey = 'available';
  static const String _storageUsagePercentKey = 'usagePercent';

  /// Returns storage information as a map with:
  /// - 'total': total storage in bytes (int)
  /// - 'used': used storage in bytes (int)
  /// - 'available': available storage in bytes (int)
  /// - 'usagePercent': usage percentage 0-100 (int)
  /// Returns null if unavailable / error.
  static Future<Map<String, int>?> getStorageInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('getStorageInfo');
      if (result == null) return null;
      
      // Convert to Map<String, int>
      // Handle both int and int64 (Long) types from native code
      final storageInfo = <String, int>{};
      
      // Helper to convert dynamic to int
      int? toInt(Object? value) {
        if (value is int) return value;
        if (value is num) return value.toInt();
        return null;
      }
      
      final total = toInt(result[_storageTotalKey]);
      final used = toInt(result[_storageUsedKey]);
      final available = toInt(result[_storageAvailableKey]);
      final usagePercent = toInt(result[_storageUsagePercentKey]);
      
      if (total != null) storageInfo[_storageTotalKey] = total;
      if (used != null) storageInfo[_storageUsedKey] = used;
      if (available != null) storageInfo[_storageAvailableKey] = available;
      if (usagePercent != null) storageInfo[_storageUsagePercentKey] = usagePercent;
      
      return storageInfo.isNotEmpty ? storageInfo : null;
    } on PlatformException catch (e) {
      debugPrint('DeviceSensorService.getStorageInfo PlatformException: ${e.code} ${e.message}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
