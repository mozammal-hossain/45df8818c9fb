/// Domain entity: analytics summary from the API.
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
}
