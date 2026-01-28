import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/core/error/failures.dart';
import 'package:device_vital_monitor_flutter_app/core/error/result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/sensor_data.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/device_repository.dart';

@injectable
class GetSensorDataUsecase {
  GetSensorDataUsecase(this._deviceRepository);

  final DeviceRepository _deviceRepository;

  Future<Result<SensorData>> call() async {
    try {
      final data = await _deviceRepository.getSensorData();
      return Success(data);
    } on PlatformException catch (e) {
      return Error(PlatformFailure(e.message ?? 'Platform error'));
    } catch (e) {
      return Error(UnexpectedFailure(e.toString()));
    }
  }
}
