import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:device_vital_monitor_flutter_app/core/error/exceptions.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/analytics_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/vitals_repository.dart';
import 'package:device_vital_monitor_flutter_app/domain/usecases/get_analytics_usecase.dart';

class MockVitalsRepository extends Mock implements VitalsRepository {}

void main() {
  late GetAnalyticsUsecase usecase;
  late MockVitalsRepository mockVitalsRepository;

  setUp(() {
    mockVitalsRepository = MockVitalsRepository();
    usecase = GetAnalyticsUsecase(mockVitalsRepository);
  });

  group('GetAnalyticsUsecase', () {
    test('delegates to getAnalytics and returns result', () async {
      const result = AnalyticsResult(
        rollingWindowLogs: 10,
        averageThermal: 1.5,
        averageBattery: 80.0,
        averageMemory: 45.0,
        totalLogs: 100,
      );
      when(
        () => mockVitalsRepository.getAnalytics(),
      ).thenAnswer((_) async => result);

      final actual = await usecase.call();

      expect(actual, result);
      verify(() => mockVitalsRepository.getAnalytics()).called(1);
    });

    test('propagates VitalsRepositoryException from repository', () async {
      when(
        () => mockVitalsRepository.getAnalytics(),
      ).thenThrow(const VitalsRepositoryException('Unavailable', 503));

      expect(() => usecase.call(), throwsA(isA<VitalsRepositoryException>()));
    });
  });
}
