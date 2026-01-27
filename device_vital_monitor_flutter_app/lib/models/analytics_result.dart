/// Response from GET /api/vitals/analytics.
class AnalyticsResult {
  const AnalyticsResult({
    required this.rollingWindowLogs,
    required this.averageThermal,
    required this.averageBattery,
    required this.averageMemory,
    required this.totalLogs,
  });

  final int rollingWindowLogs;
  final double averageThermal;
  final double averageBattery;
  final double averageMemory;
  final int totalLogs;

  factory AnalyticsResult.fromJson(Map<String, dynamic> json) {
    int toInt(Object? v) => (v is int) ? v : (v is num ? v.toInt() : 0);
    double toDouble(Object? v) =>
        (v is num) ? v.toDouble() : (double.tryParse('$v') ?? 0);

    return AnalyticsResult(
      rollingWindowLogs: toInt(json['rollingWindowLogs']),
      averageThermal: toDouble(json['averageThermal']),
      averageBattery: toDouble(json['averageBattery']),
      averageMemory: toDouble(json['averageMemory']),
      totalLogs: toInt(json['totalLogs']),
    );
  }
}
