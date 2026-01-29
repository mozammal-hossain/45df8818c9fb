import 'package:device_vital_monitor_flutter_app/data/models/request/vital_log_request.dart';
import 'package:device_vital_monitor_flutter_app/data/models/response/vital_log_response.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';

/// Maps [VitalLogResponse] to domain [VitalLog].
extension VitalLogResponseMapper on VitalLogResponse {
  VitalLog toDomain() => VitalLog(
    id: id,
    deviceId: deviceId,
    timestamp: timestamp,
    thermalValue: thermalValue,
    batteryLevel: batteryLevel,
    memoryUsage: memoryUsage,
  );
}

/// Maps domain [VitalLog] to [VitalLogRequest].
extension VitalLogEntityMapper on VitalLog {
  VitalLogRequest toRequest() => VitalLogRequest(
    deviceId: deviceId,
    timestamp: timestamp,
    thermalValue: thermalValue,
    batteryLevel: batteryLevel,
    memoryUsage: memoryUsage,
  );
}
