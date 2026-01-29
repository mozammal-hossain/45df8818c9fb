import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Mock [HttpClientAdapter] for testing [VitalsRemoteDatasource].
/// Configure [postVitalsStatus], [getHistoryBody]/[getHistoryStatus],
/// [getAnalyticsBody]/[getAnalyticsStatus], or [throwDioException] to control behavior.
class MockVitalsHttpAdapter implements HttpClientAdapter {
  int postVitalsStatus = 200;
  String getHistoryBody = '''
{
  "data": [],
  "page": 1,
  "page_size": 20,
  "total_count": 0,
  "total_pages": 0,
  "has_next_page": false,
  "has_previous_page": false
}
''';
  int getHistoryStatus = 200;
  String getAnalyticsBody = '''
{
  "rollingWindowLogs": 0,
  "averageThermal": 0,
  "averageBattery": 0,
  "averageMemory": 0,
  "totalLogs": 0
}
''';
  int getAnalyticsStatus = 200;

  /// If non-null, the adapter throws this instead of returning a response.
  DioException? throwDioException;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (throwDioException != null) {
      throw throwDioException!;
    }

    final path = options.path;
    final method = options.method;

    if (path.endsWith('/api/vitals/analytics') ||
        path == '/api/vitals/analytics') {
      return ResponseBody.fromString(
        getAnalyticsBody,
        getAnalyticsStatus,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    if (path.endsWith('/api/vitals') || path == '/api/vitals') {
      if (method == 'POST') {
        return ResponseBody.fromString('', postVitalsStatus);
      }
      return ResponseBody.fromString(
        getHistoryBody,
        getHistoryStatus,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    return ResponseBody.fromString('{"message":"Not found"}', 404);
  }

  @override
  void close({bool force = false}) {}
}
