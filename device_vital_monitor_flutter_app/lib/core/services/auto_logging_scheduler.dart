import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/core/config/api_config.dart';
import 'package:device_vital_monitor_flutter_app/core/error/result.dart';
import 'package:device_vital_monitor_flutter_app/data/datasources/platform/auto_logging_platform_datasource.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/device_repository.dart';
import 'package:device_vital_monitor_flutter_app/domain/usecases/get_sensor_data_usecase.dart';
import 'package:device_vital_monitor_flutter_app/domain/usecases/log_vital_snapshot_usecase.dart';

/// Interval for auto-logging (every 15 minutes per project brief).
const Duration kAutoLoggingInterval = Duration(minutes: 15);

/// Coordinates in-app periodic vital logging and native background scheduling
/// (WorkManager on Android, BGAppRefresh on iOS).
@lazySingleton
class AutoLoggingScheduler {
  AutoLoggingScheduler(
    this._logVitalSnapshot,
    this._getSensorData,
    this._deviceRepository,
    this._platformDatasource,
  ) : _apiConfig = ApiConfig();

  final LogVitalSnapshotUsecase _logVitalSnapshot;
  final GetSensorDataUsecase _getSensorData;
  final DeviceRepository _deviceRepository;
  final AutoLoggingPlatformDatasource _platformDatasource;
  final ApiConfig _apiConfig;

  Timer? _timer;

  bool get isRunning => _timer?.isActive ?? false;

  /// Starts auto-logging: in-app timer every 15 min and native background schedule.
  /// Safe to call when already running (no-op).
  Future<void> start() async {
    if (_timer != null) return;

    final deviceInfo = await _deviceRepository.getDeviceInfo();
    await _platformDatasource.scheduleBackgroundAutoLog(
      baseUrl: _apiConfig.baseUrl,
      deviceId: deviceInfo.deviceId,
    );

    _timer = Timer.periodic(kAutoLoggingInterval, (_) => _performLog());
    debugPrint(
      'AutoLoggingScheduler: started (interval ${kAutoLoggingInterval.inMinutes} min)',
    );
  }

  /// Stops auto-logging: cancels timer and native background work.
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await _platformDatasource.cancelBackgroundAutoLog();
    debugPrint('AutoLoggingScheduler: stopped');
  }

  Future<void> _performLog() async {
    final result = await _getSensorData();
    switch (result) {
      case Success(:final data):
        final t = data.thermalState;
        final b = data.batteryLevel;
        final m = data.memoryUsage;
        if (t == null || b == null || m == null) {
          debugPrint('AutoLoggingScheduler: skip log (incomplete sensor data)');
          return;
        }
        try {
          await _logVitalSnapshot(
            thermalValue: t,
            batteryLevel: b.toDouble(),
            memoryUsage: m.toDouble(),
          );
          debugPrint(
            'AutoLoggingScheduler: vital logged at ${DateTime.now().toIso8601String()}',
          );
        } catch (e, st) {
          debugPrint('AutoLoggingScheduler: log failed $e $st');
        }
      case Error(:final failure):
        debugPrint('AutoLoggingScheduler: skip log (${failure.message})');
    }
  }
}
