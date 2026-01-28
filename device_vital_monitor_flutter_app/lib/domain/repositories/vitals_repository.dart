import 'package:device_vital_monitor_flutter_app/domain/entities/analytics_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/paged_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';

/// Abstract vitals repository: log snapshot, fetch history, fetch analytics.
abstract interface class VitalsRepository {
  Future<void> logVital({
    required String deviceId,
    required DateTime timestamp,
    required int thermalValue,
    required double batteryLevel,
    required double memoryUsage,
  });
  Future<PagedResult<VitalLog>> getHistoryPage({int page = 1, int pageSize = 20});
  Future<AnalyticsResult> getAnalytics();
}
