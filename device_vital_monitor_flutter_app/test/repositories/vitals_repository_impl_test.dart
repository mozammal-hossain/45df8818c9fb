import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:device_vital_monitor_flutter_app/core/error/exceptions.dart';
import 'package:device_vital_monitor_flutter_app/data/datasources/remote/vitals_remote_datasource.dart';
import 'package:device_vital_monitor_flutter_app/data/models/request/vital_log_request.dart';
import 'package:device_vital_monitor_flutter_app/data/models/response/analytics_response.dart';
import 'package:device_vital_monitor_flutter_app/data/models/response/paged_vitals_response.dart';
import 'package:device_vital_monitor_flutter_app/data/repositories/vitals_repository_impl.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/analytics_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/paged_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';

class MockVitalsRemoteDatasource extends Mock
    implements VitalsRemoteDatasource {}

void main() {
  late VitalsRepositoryImpl repository;
  late MockVitalsRemoteDatasource mockRemote;

  setUpAll(() {
    registerFallbackValue(
      VitalLogRequest(
        deviceId: '',
        timestamp: DateTime(0),
        thermalValue: 0,
        batteryLevel: 0,
        memoryUsage: 0,
      ),
    );
  });

  setUp(() {
    mockRemote = MockVitalsRemoteDatasource();
    repository = VitalsRepositoryImpl(mockRemote);
  });

  group('VitalsRepositoryImpl - logVital', () {
    test('builds VitalLogRequest and calls remote.logVital', () async {
      when(() => mockRemote.logVital(any())).thenAnswer((_) async {});

      await repository.logVital(
        deviceId: 'device-1',
        timestamp: DateTime.utc(2025, 1, 15, 12, 0),
        thermalValue: 2,
        batteryLevel: 85.5,
        memoryUsage: 42.0,
      );

      final captured = verify(() => mockRemote.logVital(captureAny())).captured;
      expect(captured.length, 1);
      final request = captured[0] as VitalLogRequest;
      expect(request.deviceId, 'device-1');
      expect(request.timestamp, DateTime.utc(2025, 1, 15, 12, 0));
      expect(request.thermalValue, 2);
      expect(request.batteryLevel, 85.5);
      expect(request.memoryUsage, 42.0);
    });

    test('propagates VitalsRepositoryException from remote', () async {
      when(
        () => mockRemote.logVital(any()),
      ).thenThrow(const VitalsRepositoryException('Server error', 500));

      expect(
        () => repository.logVital(
          deviceId: 'device-1',
          timestamp: DateTime.now().toUtc(),
          thermalValue: 0,
          batteryLevel: 50.0,
          memoryUsage: 50.0,
        ),
        throwsA(isA<VitalsRepositoryException>()),
      );
    });
  });

  group('VitalsRepositoryImpl - getHistoryPage', () {
    test('returns domain PagedResult from remote response', () async {
      final response = PagedVitalsResponse(
        data: [],
        page: 1,
        pageSize: 20,
        totalCount: 0,
        totalPages: 0,
        hasNextPage: false,
        hasPreviousPage: false,
      );
      when(
        () => mockRemote.getHistoryPage(page: 1, pageSize: 20),
      ).thenAnswer((_) async => response);

      final result = await repository.getHistoryPage(page: 1, pageSize: 20);

      expect(result, isA<PagedResult<VitalLog>>());
      expect(result.items, isEmpty);
      expect(result.page, 1);
      expect(result.pageSize, 20);
      expect(result.totalCount, 0);
    });

    test('passes custom page and pageSize to remote', () async {
      final response = const PagedVitalsResponse(
        data: [],
        page: 2,
        pageSize: 10,
        totalCount: 0,
        totalPages: 0,
        hasNextPage: false,
        hasPreviousPage: false,
      );
      when(
        () => mockRemote.getHistoryPage(page: 2, pageSize: 10),
      ).thenAnswer((_) async => response);

      final result = await repository.getHistoryPage(page: 2, pageSize: 10);

      expect(result.page, 2);
      expect(result.pageSize, 10);
      verify(() => mockRemote.getHistoryPage(page: 2, pageSize: 10)).called(1);
    });

    test('propagates VitalsRepositoryException from remote', () async {
      when(
        () => mockRemote.getHistoryPage(page: 1, pageSize: 20),
      ).thenThrow(const VitalsRepositoryException('Timeout', null));

      expect(
        () => repository.getHistoryPage(),
        throwsA(isA<VitalsRepositoryException>()),
      );
    });
  });

  group('VitalsRepositoryImpl - getAnalytics', () {
    test('returns domain AnalyticsResult from remote response', () async {
      const response = AnalyticsResponse(
        rollingWindowLogs: 10,
        averageThermal: 1.5,
        averageBattery: 80.0,
        averageMemory: 45.0,
        totalLogs: 100,
      );
      when(() => mockRemote.getAnalytics()).thenAnswer((_) async => response);

      final result = await repository.getAnalytics();

      expect(result, isA<AnalyticsResult>());
      expect(result.rollingWindowLogs, 10);
      expect(result.averageThermal, 1.5);
      expect(result.averageBattery, 80.0);
      expect(result.averageMemory, 45.0);
      expect(result.totalLogs, 100);
    });

    test('propagates VitalsRepositoryException from remote', () async {
      when(
        () => mockRemote.getAnalytics(),
      ).thenThrow(const VitalsRepositoryException('Unavailable', 503));

      expect(
        () => repository.getAnalytics(),
        throwsA(isA<VitalsRepositoryException>()),
      );
    });
  });
}
