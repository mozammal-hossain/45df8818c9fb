/// Domain entity: a single vital log entry from the API.
///
/// [timestamp] is always in UTC (API contract). Use [timestamp.toLocal()] for display.
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

  /// UTC timestamp from API. Convert with [DateTime.toLocal] for user-facing display.
  final DateTime timestamp;
  final int thermalValue;
  final double batteryLevel;
  final double memoryUsage;
}
