import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';

/// API response model for a single vital log.
///
/// API contract: backend sends timestamps in UTC (ISO8601 with Z).
/// We parse as UTC; UI displays using [timestamp.toLocal()].
class VitalLogResponse {
  const VitalLogResponse({
    required this.id,
    required this.deviceId,
    required this.timestamp,
    required this.thermalValue,
    required this.batteryLevel,
    required this.memoryUsage,
  });

  final int id;
  final String deviceId;

  /// UTC timestamp from API. Use [DateTime.toLocal] for display.
  final DateTime timestamp;
  final int thermalValue;
  final double batteryLevel;
  final double memoryUsage;

  /// Parses API timestamp string (UTC) into [DateTime] in UTC.
  static DateTime _parseUtcTimestamp(Object? v) {
    if (v == null) return DateTime.now().toUtc();
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return DateTime.now().toUtc();
      final parsed = DateTime.tryParse(s);
      if (parsed != null) return parsed.toUtc();
      return DateTime.now().toUtc();
    }
    return DateTime.now().toUtc();
  }

  factory VitalLogResponse.fromJson(Map<String, dynamic> json) {
    int toInt(Object? v) => (v is int) ? v : (v is num ? v.toInt() : 0);
    double toDouble(Object? v) =>
        (v is num) ? v.toDouble() : (double.tryParse('$v') ?? 0);

    return VitalLogResponse(
      id: toInt(json['id']),
      deviceId: json['deviceId'] as String? ?? '',
      timestamp: _parseUtcTimestamp(json['timestamp']),
      thermalValue: toInt(json['thermalValue']),
      batteryLevel: toDouble(json['batteryLevel']),
      memoryUsage: toDouble(json['memoryUsage']),
    );
  }

  VitalLog toEntity() => VitalLog(
    id: id,
    deviceId: deviceId,
    timestamp: timestamp,
    thermalValue: thermalValue,
    batteryLevel: batteryLevel,
    memoryUsage: memoryUsage,
  );
}
