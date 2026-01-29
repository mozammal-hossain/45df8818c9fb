import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:device_vital_monitor_flutter_app/core/config/api_config.dart';
import 'package:device_vital_monitor_flutter_app/core/error/exceptions.dart';
import 'package:device_vital_monitor_flutter_app/data/datasources/remote/vitals_remote_datasource.dart';
import 'package:device_vital_monitor_flutter_app/data/models/request/vital_log_request.dart';
import 'mock_vitals_http_adapter.dart';

void main() {
  late VitalsRemoteDatasource datasource;
  late MockVitalsHttpAdapter mockAdapter;
  late Dio dio;

  setUp(() {
    mockAdapter = MockVitalsHttpAdapter();
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://test',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );
    dio.httpClientAdapter = mockAdapter;
    final config = ApiConfig(baseUrl: 'http://test');
    datasource = VitalsRemoteDatasource(dio: dio, apiConfig: config);
  });

  group('VitalsRemoteDatasource - logVital', () {
    test('succeeds when server returns 200', () async {
      mockAdapter.postVitalsStatus = 200;

      final request = VitalLogRequest(
        deviceId: 'device-1',
        timestamp: DateTime.utc(2025, 1, 1, 12, 0),
        thermalValue: 1,
        batteryLevel: 85.0,
        memoryUsage: 45.0,
      );

      await expectLater(datasource.logVital(request), completes);
    });

    test('throws VitalsRepositoryException when server returns 400', () async {
      mockAdapter.postVitalsStatus = 400;

      final request = VitalLogRequest(
        deviceId: 'device-1',
        timestamp: DateTime.now().toUtc(),
        thermalValue: 0,
        batteryLevel: 50.0,
        memoryUsage: 50.0,
      );

      expect(
        () => datasource.logVital(request),
        throwsA(
          isA<VitalsRepositoryException>().having(
            (e) => e.statusCode,
            'statusCode',
            400,
          ),
        ),
      );
    });

    test('throws VitalsRepositoryException when server returns 500', () async {
      mockAdapter.postVitalsStatus = 500;

      final request = VitalLogRequest(
        deviceId: 'device-1',
        timestamp: DateTime.now().toUtc(),
        thermalValue: 1,
        batteryLevel: 50.0,
        memoryUsage: 50.0,
      );

      expect(
        () => datasource.logVital(request),
        throwsA(
          isA<VitalsRepositoryException>().having(
            (e) => e.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });

    test('throws VitalsRepositoryException on connection timeout', () async {
      mockAdapter.throwDioException = DioException(
        requestOptions: RequestOptions(path: '/api/vitals'),
        type: DioExceptionType.connectionTimeout,
      );

      final request = VitalLogRequest(
        deviceId: 'device-1',
        timestamp: DateTime.now().toUtc(),
        thermalValue: 1,
        batteryLevel: 50.0,
        memoryUsage: 50.0,
      );

      expect(
        () => datasource.logVital(request),
        throwsA(isA<VitalsRepositoryException>()),
      );
    });

    test('throws VitalsRepositoryException on connection error', () async {
      mockAdapter.throwDioException = DioException(
        requestOptions: RequestOptions(path: '/api/vitals'),
        type: DioExceptionType.connectionError,
      );

      final request = VitalLogRequest(
        deviceId: 'device-1',
        timestamp: DateTime.now().toUtc(),
        thermalValue: 1,
        batteryLevel: 50.0,
        memoryUsage: 50.0,
      );

      expect(
        () => datasource.logVital(request),
        throwsA(isA<VitalsRepositoryException>()),
      );
    });
  });

  group('VitalsRemoteDatasource - getHistoryPage', () {
    test('returns empty page when server returns empty data', () async {
      mockAdapter.getHistoryBody = jsonEncode({
        'data': <Map<String, dynamic>>[],
        'page': 1,
        'page_size': 20,
        'total_count': 0,
        'total_pages': 0,
        'has_next_page': false,
        'has_previous_page': false,
      });
      mockAdapter.getHistoryStatus = 200;

      final result = await datasource.getHistoryPage(page: 1, pageSize: 20);

      expect(result.data, isEmpty);
      expect(result.page, 1);
      expect(result.pageSize, 20);
      expect(result.totalCount, 0);
      expect(result.totalPages, 0);
      expect(result.hasNextPage, false);
      expect(result.hasPreviousPage, false);
    });

    test('returns mapped page when server returns one log', () async {
      mockAdapter.getHistoryBody = jsonEncode({
        'data': [
          {
            'id': 42,
            'deviceId': 'dev-1',
            'timestamp': '2025-01-15T10:00:00.000Z',
            'thermalValue': 2,
            'batteryLevel': 70.0,
            'memoryUsage': 55.0,
          },
        ],
        'page': 1,
        'page_size': 20,
        'total_count': 1,
        'total_pages': 1,
        'has_next_page': false,
        'has_previous_page': false,
      });
      mockAdapter.getHistoryStatus = 200;

      final result = await datasource.getHistoryPage(page: 1, pageSize: 20);

      expect(result.data.length, 1);
      expect(result.data[0].id, 42);
      expect(result.data[0].deviceId, 'dev-1');
      expect(result.data[0].thermalValue, 2);
      expect(result.data[0].batteryLevel, 70.0);
      expect(result.data[0].memoryUsage, 55.0);
      expect(result.page, 1);
      expect(result.totalCount, 1);
    });

    test('uses custom page and pageSize in request', () async {
      mockAdapter.getHistoryBody = jsonEncode({
        'data': <Map<String, dynamic>>[],
        'page': 2,
        'page_size': 10,
        'total_count': 0,
        'total_pages': 0,
        'has_next_page': false,
        'has_previous_page': false,
      });

      final result = await datasource.getHistoryPage(page: 2, pageSize: 10);

      expect(result.page, 2);
      expect(result.pageSize, 10);
    });

    test('returns empty page for minimal valid JSON', () async {
      mockAdapter.getHistoryBody = jsonEncode({
        'data': <Map<String, dynamic>>[],
        'page': 1,
        'page_size': 20,
        'total_count': 0,
        'total_pages': 0,
        'has_next_page': false,
        'has_previous_page': false,
      });
      mockAdapter.getHistoryStatus = 200;

      final result = await datasource.getHistoryPage();

      expect(result.data, isEmpty);
      expect(result.page, 1);
      expect(result.pageSize, 20);
    });

    test('throws VitalsRepositoryException when server returns 500', () async {
      mockAdapter.getHistoryStatus = 500;
      mockAdapter.getHistoryBody = '{"message":"Server error"}';

      expect(
        () => datasource.getHistoryPage(),
        throwsA(
          isA<VitalsRepositoryException>().having(
            (e) => e.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });

    test('throws VitalsRepositoryException on connection error', () async {
      mockAdapter.throwDioException = DioException(
        requestOptions: RequestOptions(path: '/api/vitals'),
        type: DioExceptionType.connectionError,
      );

      expect(
        () => datasource.getHistoryPage(),
        throwsA(isA<VitalsRepositoryException>()),
      );
    });
  });

  group('VitalsRemoteDatasource - getAnalytics', () {
    test('returns analytics when server returns 200', () async {
      mockAdapter.getAnalyticsBody = jsonEncode({
        'rollingWindowLogs': 10,
        'averageThermal': 1.5,
        'averageBattery': 80.0,
        'averageMemory': 45.0,
        'totalLogs': 100,
      });
      mockAdapter.getAnalyticsStatus = 200;

      final result = await datasource.getAnalytics();

      expect(result.rollingWindowLogs, 10);
      expect(result.averageThermal, 1.5);
      expect(result.averageBattery, 80.0);
      expect(result.averageMemory, 45.0);
      expect(result.totalLogs, 100);
    });

    test(
      'returns zeroed analytics when server returns empty-like data',
      () async {
        mockAdapter.getAnalyticsBody = jsonEncode({
          'rollingWindowLogs': 0,
          'averageThermal': 0,
          'averageBattery': 0,
          'averageMemory': 0,
          'totalLogs': 0,
        });

        final result = await datasource.getAnalytics();

        expect(result.rollingWindowLogs, 0);
        expect(result.totalLogs, 0);
      },
    );

    test('throws VitalsRepositoryException when server returns 400', () async {
      mockAdapter.getAnalyticsStatus = 400;
      mockAdapter.getAnalyticsBody = '{"message":"Bad request"}';

      expect(
        () => datasource.getAnalytics(),
        throwsA(
          isA<VitalsRepositoryException>().having(
            (e) => e.statusCode,
            'statusCode',
            400,
          ),
        ),
      );
    });

    test('throws VitalsRepositoryException on timeout', () async {
      mockAdapter.throwDioException = DioException(
        requestOptions: RequestOptions(path: '/api/vitals/analytics'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(
        () => datasource.getAnalytics(),
        throwsA(isA<VitalsRepositoryException>()),
      );
    });
  });
}
