import 'package:device_vital_monitor_flutter_app/domain/entities/analytics_result.dart';

/// API response model for vitals analytics (backend returns snake_case).
class AnalyticsResponse {
  const AnalyticsResponse({
    required this.rollingWindowLogs,
    required this.averageThermal,
    required this.averageBattery,
    required this.averageMemory,
    required this.totalLogs,
    this.trendThermal = 'insufficient_data',
    this.trendBattery = 'insufficient_data',
    this.trendMemory = 'insufficient_data',
  });

  final int rollingWindowLogs;
  final double averageThermal;
  final double averageBattery;
  final double averageMemory;
  final int totalLogs;
  final String trendThermal;
  final String trendBattery;
  final String trendMemory;

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    int toInt(Object? v) => (v is int) ? v : (v is num ? v.toInt() : 0);
    double toDouble(Object? v) =>
        (v is num) ? v.toDouble() : (double.tryParse('$v') ?? 0);
    String str(Object? v) => (v is String) ? v : 'insufficient_data';
    return AnalyticsResponse(
      rollingWindowLogs: toInt(json['rolling_window_logs']),
      averageThermal: toDouble(json['average_thermal']),
      averageBattery: toDouble(json['average_battery']),
      averageMemory: toDouble(json['average_memory']),
      totalLogs: toInt(json['total_logs']),
      trendThermal: str(json['trend_thermal']),
      trendBattery: str(json['trend_battery']),
      trendMemory: str(json['trend_memory']),
    );
  }

  AnalyticsResult toEntity() => AnalyticsResult(
    rollingWindowLogs: rollingWindowLogs,
    averageThermal: averageThermal,
    averageBattery: averageBattery,
    averageMemory: averageMemory,
    totalLogs: totalLogs,
    trendThermal: trendThermal,
    trendBattery: trendBattery,
    trendMemory: trendMemory,
  );
}
