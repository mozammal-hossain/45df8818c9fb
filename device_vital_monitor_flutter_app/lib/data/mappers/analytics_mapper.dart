import 'package:device_vital_monitor_flutter_app/data/models/response/analytics_response.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/analytics_result.dart';

/// Maps [AnalyticsResponse] to domain [AnalyticsResult].
extension AnalyticsResponseMapper on AnalyticsResponse {
  AnalyticsResult toDomain() => AnalyticsResult(
        rollingWindowLogs: rollingWindowLogs,
        averageThermal: averageThermal,
        averageBattery: averageBattery,
        averageMemory: averageMemory,
        totalLogs: totalLogs,
      );
}
