/// A single vital log entry from GET /api/vitals (backend DeviceVital).
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

  factory VitalLog.fromJson(Map<String, dynamic> json) {
    int toInt(Object? v) => (v is int) ? v : (v is num ? v.toInt() : 0);
    double toDouble(Object? v) =>
        (v is num) ? v.toDouble() : (double.tryParse('$v') ?? 0);

    DateTime parseTimestamp(Object? v) {
      if (v == null) return DateTime.now().toUtc();
      if (v is String) return DateTime.tryParse(v)?.toUtc() ?? DateTime.now().toUtc();
      return DateTime.now().toUtc();
    }

    return VitalLog(
      id: toInt(json['id']),
      deviceId: json['deviceId'] as String? ?? '',
      timestamp: parseTimestamp(json['timestamp']),
      thermalValue: toInt(json['thermalValue']),
      batteryLevel: toDouble(json['batteryLevel']),
      memoryUsage: toDouble(json['memoryUsage']),
    );
  }
}
