import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import '../models/storage_info.dart';

/// Service for reading device sensors via native MethodChannel.
/// Uses [device_vital_monitor/sensors] channel (Android MainActivity).
@lazySingleton
class DeviceSensorService {
  DeviceSensorService();
  static const _channel = MethodChannel('device_vital_monitor/sensors');

  /// Returns thermal state 0-3, or null if unavailable / error.
  /// 0 = NONE, 1 = LIGHT, 2 = MODERATE, 3 = SEVERE
  Future<int?> getThermalState() async {
    try {
      final state = await _channel.invokeMethod<int>('getThermalState');
      return state;
    } on PlatformException catch (e) {
      debugPrint(
        'DeviceSensorService.getThermalState PlatformException: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Returns battery level 0-100, or null if unavailable / error.
  Future<int?> getBatteryLevel() async {
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
  Future<String?> getBatteryHealth() async {
    try {
      final result = await _channel.invokeMethod<Object?>('getBatteryHealth');
      if (result == null) return null;
      return result is String ? result : result.toString();
    } on PlatformException catch (e) {
      debugPrint(
        'DeviceSensorService.getBatteryHealth PlatformException: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Returns charger connection type: AC, USB, WIRELESS, or NONE.
  /// Null if unavailable / error.
  Future<String?> getChargerConnection() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        'getChargerConnection',
      );
      if (result == null) return null;
      return result is String ? result : result.toString();
    } on PlatformException catch (e) {
      debugPrint(
        'DeviceSensorService.getChargerConnection PlatformException: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Returns battery status: CHARGING, DISCHARGING, FULL, NOT_CHARGING, or UNKNOWN.
  /// Null if unavailable / error.
  Future<String?> getBatteryStatus() async {
    try {
      final result = await _channel.invokeMethod<Object?>('getBatteryStatus');
      if (result == null) return null;
      return result is String ? result : result.toString();
    } on PlatformException catch (e) {
      debugPrint(
        'DeviceSensorService.getBatteryStatus PlatformException: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Returns memory usage as percentage 0–100 (system-wide on Android, process vs total on iOS).
  /// Null if unavailable / error.
  Future<int?> getMemoryUsage() async {
    try {
      final level = await _channel.invokeMethod<int>('getMemoryUsage');
      return level;
    } on PlatformException catch (e) {
      debugPrint(
        'DeviceSensorService.getMemoryUsage PlatformException: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Returns storage information as a [StorageInfo] model.
  /// Returns null if unavailable / error.
  Future<StorageInfo?> getStorageInfo() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'getStorageInfo',
      );
      if (result == null) return null;

      // Convert Map<Object?, Object?> to Map<String, dynamic> for fromJson
      final jsonMap = <String, dynamic>{};
      for (final entry in result.entries) {
        final key = entry.key?.toString();
        if (key != null) {
          jsonMap[key] = entry.value;
        }
      }

      return StorageInfo.fromJson(jsonMap);
    } on PlatformException catch (e) {
      debugPrint(
        'DeviceSensorService.getStorageInfo PlatformException: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    } catch (e) {
      debugPrint(
        'DeviceSensorService.getStorageInfo error: $e',
      );
      return null;
    }
  }
}
