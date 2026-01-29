import 'package:device_vital_monitor_flutter_app/data/models/response/vital_log_response.dart';

/// API response for GET /api/vitals with pagination.
class PagedVitalsResponse {
  const PagedVitalsResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final List<VitalLogResponse> data;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  factory PagedVitalsResponse.fromJson(Map<String, dynamic> json) {
    int toInt(Object? v) => (v is int) ? v : (v is num ? v.toInt() : 0);
    final rawList = json['data'];
    final list = rawList is List
        ? rawList
              .whereType<Map<String, dynamic>>()
              .map((e) => VitalLogResponse.fromJson(e))
              .toList()
        : <VitalLogResponse>[];
    return PagedVitalsResponse(
      data: list,
      page: toInt(json['page']),
      pageSize: toInt(json['page_size']),
      totalCount: toInt(json['total_count']),
      totalPages: toInt(json['total_pages']),
      hasNextPage: json['has_next_page'] == true,
      hasPreviousPage: json['has_previous_page'] == true,
    );
  }
}
