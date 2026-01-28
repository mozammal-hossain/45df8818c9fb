import 'package:device_vital_monitor_flutter_app/domain/entities/device_info.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/sensor_data.dart';

/// Abstract device repository: device id and sensor snapshot.
abstract interface class DeviceRepository {
  Future<DeviceInfo> getDeviceInfo();
  Future<SensorData> getSensorData();
  Stream<int?> get thermalStatusChangeStream;
}
