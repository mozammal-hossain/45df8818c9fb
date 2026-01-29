/// Request body for POST /api/vitals.
///
/// API contract: timestamps are sent in UTC (ISO8601 with Z).
class VitalLogRequest {
  const VitalLogRequest({
    required this.deviceId,
    required this.timestamp,
    required this.thermalValue,
    required this.batteryLevel,
    required this.memoryUsage,
  });

  final String deviceId;

  /// UTC timestamp; serialized as ISO8601 with Z.
  final DateTime timestamp;
  final int thermalValue;
  final double batteryLevel;
  final double memoryUsage;

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'thermal_value': thermalValue,
      'battery_level': batteryLevel,
      'memory_usage': memoryUsage,
    };
  }
}
