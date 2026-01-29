import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:device_vital_monitor_flutter_app/core/error/exceptions.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/paged_result.dart';
import 'package:device_vital_monitor_flutter_app/domain/entities/vital_log.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/vitals_repository.dart';
import 'package:device_vital_monitor_flutter_app/domain/usecases/get_history_usecase.dart';

class MockVitalsRepository extends Mock implements VitalsRepository {}

void main() {
  late GetHistoryUsecase usecase;
  late MockVitalsRepository mockVitalsRepository;

  setUp(() {
    mockVitalsRepository = MockVitalsRepository();
    usecase = GetHistoryUsecase(mockVitalsRepository);
  });

  group('GetHistoryUsecase', () {
    test(
      'delegates to getHistoryPage with default page and pageSize',
      () async {
        const result = PagedResult<VitalLog>(
          items: [],
          page: 1,
          pageSize: 20,
          totalCount: 0,
          totalPages: 0,
          hasNextPage: false,
          hasPreviousPage: false,
        );
        when(
          () => mockVitalsRepository.getHistoryPage(page: 1, pageSize: 20),
        ).thenAnswer((_) async => result);

        final actual = await usecase.call();

        expect(actual, result);
        verify(
          () => mockVitalsRepository.getHistoryPage(page: 1, pageSize: 20),
        ).called(1);
      },
    );

    test('delegates to getHistoryPage with custom page and pageSize', () async {
      const result = PagedResult<VitalLog>(
        items: [],
        page: 2,
        pageSize: 10,
        totalCount: 0,
        totalPages: 0,
        hasNextPage: false,
        hasPreviousPage: false,
      );
      when(
        () => mockVitalsRepository.getHistoryPage(page: 2, pageSize: 10),
      ).thenAnswer((_) async => result);

      final actual = await usecase.call(page: 2, pageSize: 10);

      expect(actual, result);
      verify(
        () => mockVitalsRepository.getHistoryPage(page: 2, pageSize: 10),
      ).called(1);
    });

    test('propagates VitalsRepositoryException from repository', () async {
      when(
        () => mockVitalsRepository.getHistoryPage(page: 1, pageSize: 20),
      ).thenThrow(const VitalsRepositoryException('Timeout', null));

      expect(() => usecase.call(), throwsA(isA<VitalsRepositoryException>()));
    });
  });
}
