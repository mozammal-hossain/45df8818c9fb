import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/domain/entities/device_info.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/sensor_data.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/storage_info.dart'
    as domain;
import 'package:device_vital_monitor_flutter_app/domain/repositories/device_repository.dart';
import 'package:device_vital_monitor_flutter_app/data/datasources/local/device_id_local_datasource.dart';
import 'package:device_vital_monitor_flutter_app/data/datasources/platform/sensor_platform_datasource.dart';
import 'package:device_vital_monitor_flutter_app/data/models/local/storage_info.dart'
    as local;

@LazySingleton(as: DeviceRepository)
class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl(this._deviceIdLocal, this._sensorPlatform);

  final DeviceIdLocalDatasource _deviceIdLocal;
  final SensorPlatformDatasource _sensorPlatform;

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    final id = await _deviceIdLocal.getOrCreateDeviceId();
    return DeviceInfo(id);
  }

  @override
  Future<SensorData> getSensorData() async {
    final results = await Future.wait([
      _sensorPlatform.getThermalState(),
      _sensorPlatform.getThermalHeadroom(),
      _sensorPlatform.getBatteryLevel(),
      _sensorPlatform.getBatteryHealth(),
      _sensorPlatform.getChargerConnection(),
      _sensorPlatform.getBatteryStatus(),
      _sensorPlatform.getMemoryUsage(),
      _sensorPlatform.getStorageInfo(),
    ]);
    domain.StorageInfo? storageEntity;
    final s = results[7];
    if (s != null && s is local.StorageInfo) {
      storageEntity = s.toEntity();
    }
    return SensorData(
      thermalState: results[0] as int?,
      thermalHeadroom: results[1] as double?,
      batteryLevel: results[2] as int?,
      batteryHealth: results[3] as String?,
      chargerConnection: results[4] as String?,
      batteryStatus: results[5] as String?,
      memoryUsage: results[6] as int?,
      storageInfo: storageEntity,
    );
  }

  @override
  Stream<int?> get thermalStatusChangeStream =>
      _sensorPlatform.thermalStatusChangeStream;
}
