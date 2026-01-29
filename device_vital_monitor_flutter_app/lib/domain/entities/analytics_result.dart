/// Domain entity: analytics summary from the API.
class AnalyticsResult {
  const AnalyticsResult({
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

  /// One of: increasing, decreasing, stable, insufficient_data
  final String trendThermal;
  final String trendBattery;
  final String trendMemory;
}
