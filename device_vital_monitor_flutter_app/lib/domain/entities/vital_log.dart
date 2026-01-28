/// Domain entity: a single vital log entry from the API.
class VitalLog {
  const VitalLog({
    required this.id,
    required this.deviceId,
    required this.timestamp,
    required this.thermalValue,
    required this.batteryLevel,
    required this.memoryUsage,
  });

  final int id;
  final String deviceId;
  final DateTime timestamp;
  final int thermalValue;
  final double batteryLevel;
  final double memoryUsage;
}
