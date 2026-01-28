import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/domain/repositories/device_repository.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/vitals_repository.dart';

@injectable
class LogVitalSnapshotUsecase {
  LogVitalSnapshotUsecase(this._vitalsRepository, this._deviceRepository);

  final VitalsRepository _vitalsRepository;
  final DeviceRepository _deviceRepository;

  Future<void> call({
    required int thermalValue,
    required double batteryLevel,
    required double memoryUsage,
  }) async {
    final device = await _deviceRepository.getDeviceInfo();
    await _vitalsRepository.logVital(
      deviceId: device.deviceId,
      timestamp: DateTime.now().toUtc(),
      thermalValue: thermalValue.clamp(0, 3),
      batteryLevel: batteryLevel.clamp(0, 100),
      memoryUsage: memoryUsage.clamp(0, 100),
    );
  }
}
