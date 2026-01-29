import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/core/platform/method_channels.dart';

@lazySingleton
class SensorPlatformDatasource {
  SensorPlatformDatasource() {
    _channel = const MethodChannel(MethodChannels.sensors);
    _thermalEventChannel = const EventChannel(MethodChannels.thermalEvents);
  }

  late final MethodChannel _channel;
  late final EventChannel _thermalEventChannel;

  Future<int?> getThermalState() async {
    try {
      return await _channel.invokeMethod<int>(SensorMethods.getThermalState);
    } on PlatformException catch (e) {
      debugPrint(
        'SensorPlatformDatasource.getThermalState: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<double?> getThermalHeadroom({int forecastSeconds = 10}) async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        SensorMethods.getThermalHeadroom,
        forecastSeconds.clamp(0, 60),
      );
      if (result == null) return null;
      if (result is double) return result;
      if (result is int) return result.toDouble();
      return double.tryParse(result.toString());
    } on PlatformException catch (e) {
      debugPrint(
        'SensorPlatformDatasource.getThermalHeadroom: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Stream<int?> get thermalStatusChangeStream => _thermalEventChannel
      .receiveBroadcastStream()
      .map<int?>((e) {
        if (e == null) return null;
        if (e is int) return e;
        return int.tryParse(e.toString());
      })
      .handleError((Object error, StackTrace stackTrace) {});

  Future<int?> getBatteryLevel() async {
    try {
      return await _channel.invokeMethod<int>(SensorMethods.getBatteryLevel);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<String?> getBatteryHealth() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        SensorMethods.getBatteryHealth,
      );
      if (result == null) return null;
      return result is String ? result : result.toString();
    } on PlatformException catch (e) {
      debugPrint(
        'SensorPlatformDatasource.getBatteryHealth: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<String?> getChargerConnection() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        SensorMethods.getChargerConnection,
      );
      if (result == null) return null;
      return result is String ? result : result.toString();
    } on PlatformException catch (e) {
      debugPrint(
        'SensorPlatformDatasource.getChargerConnection: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<String?> getBatteryStatus() async {
    try {
      final result = await _channel.invokeMethod<Object?>(
        SensorMethods.getBatteryStatus,
      );
      if (result == null) return null;
      return result is String ? result : result.toString();
    } on PlatformException catch (e) {
      debugPrint(
        'SensorPlatformDatasource.getBatteryStatus: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<int?> getMemoryUsage() async {
    try {
      return await _channel.invokeMethod<int>(SensorMethods.getMemoryUsage);
    } on PlatformException catch (e) {
      debugPrint(
        'SensorPlatformDatasource.getMemoryUsage: ${e.code} ${e.message}',
      );
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
