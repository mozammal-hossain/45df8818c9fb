import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/data/datasources/remote/vitals_remote_datasource.dart';
import 'package:device_vital_monitor_flutter_app/data/mappers/analytics_mapper.dart';
import 'package:device_vital_monitor_flutter_app/data/mappers/paged_vitals_mapper.dart';
import 'package:device_vital_monitor_flutter_app/data/models/request/vital_log_request.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/analytics_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/paged_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/vitals_repository.dart';

@LazySingleton(as: VitalsRepository)
class VitalsRepositoryImpl implements VitalsRepository {
  VitalsRepositoryImpl(this._remote);

  final VitalsRemoteDatasource _remote;

  @override
  Future<void> logVital({
    required String deviceId,
    required DateTime timestamp,
    required int thermalValue,
    required double batteryLevel,
    required double memoryUsage,
  }) async {
    final request = VitalLogRequest(
      deviceId: deviceId,
      timestamp: timestamp,
      thermalValue: thermalValue,
      batteryLevel: batteryLevel,
      memoryUsage: memoryUsage,
    );
    await _remote.logVital(request);
  }

  @override
  Future<PagedResult<VitalLog>> getHistoryPage({
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _remote.getHistoryPage(page: page, pageSize: pageSize);
    return res.toDomain();
  }

  @override
  Future<AnalyticsResult> getAnalytics() async {
    final response = await _remote.getAnalytics();
    return response.toDomain();
  }
}
