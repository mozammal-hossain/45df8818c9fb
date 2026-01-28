import 'package:device_vital_monitor_flutter_app/data/models/response/paged_vitals_response.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/paged_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';

extension PagedVitalsResponseMapper on PagedVitalsResponse {
  PagedResult<VitalLog> toDomain() => PagedResult<VitalLog>(
        items: data.map((r) => r.toEntity()).toList(),
        page: page,
        pageSize: pageSize,
        totalCount: totalCount,
        totalPages: totalPages,
        hasNextPage: hasNextPage,
        hasPreviousPage: hasPreviousPage,
      );
}
