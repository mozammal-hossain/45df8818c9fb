import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:device_vital_monitor_flutter_app/domain/entities/device_info.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/device_repository.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/vitals_repository.dart';
import 'package:device_vital_monitor_flutter_app/domain/usecases/log_vital_snapshot_usecase.dart';

class MockVitalsRepository extends Mock implements VitalsRepository {}

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late LogVitalSnapshotUsecase usecase;
  late MockVitalsRepository mockVitalsRepository;
  late MockDeviceRepository mockDeviceRepository;

  setUp(() {
    mockVitalsRepository = MockVitalsRepository();
    mockDeviceRepository = MockDeviceRepository();
    usecase = LogVitalSnapshotUsecase(
      mockVitalsRepository,
      mockDeviceRepository,
    );
  });

  group('LogVitalSnapshotUsecase', () {
    test(
      'fetches device info then calls logVital with clamped values',
      () async {
        when(
          () => mockDeviceRepository.getDeviceInfo(),
        ).thenAnswer((_) async => const DeviceInfo('device-123'));
        when(
          () => mockVitalsRepository.logVital(
            deviceId: any(named: 'deviceId'),
            timestamp: any(named: 'timestamp'),
            thermalValue: any(named: 'thermalValue'),
            batteryLevel: any(named: 'batteryLevel'),
            memoryUsage: any(named: 'memoryUsage'),
          ),
        ).thenAnswer((_) async {});

        await usecase.call(
          thermalValue: 2,
          batteryLevel: 85.0,
          memoryUsage: 45.0,
        );

        verify(() => mockDeviceRepository.getDeviceInfo()).called(1);
        verify(
          () => mockVitalsRepository.logVital(
            deviceId: 'device-123',
            timestamp: any(named: 'timestamp'),
            thermalValue: 2,
            batteryLevel: 85.0,
            memoryUsage: 45.0,
          ),
        ).called(1);
      },
    );

    test('clamps thermalValue to 0–3', () async {
      when(
        () => mockDeviceRepository.getDeviceInfo(),
      ).thenAnswer((_) async => const DeviceInfo('dev-1'));
      when(
        () => mockVitalsRepository.logVital(
          deviceId: any(named: 'deviceId'),
          timestamp: any(named: 'timestamp'),
          thermalValue: any(named: 'thermalValue'),
          batteryLevel: any(named: 'batteryLevel'),
          memoryUsage: any(named: 'memoryUsage'),
        ),
      ).thenAnswer((_) async {});

      await usecase.call(
        thermalValue: 10,
        batteryLevel: 50.0,
        memoryUsage: 50.0,
      );

      verify(
        () => mockVitalsRepository.logVital(
          deviceId: 'dev-1',
          timestamp: any(named: 'timestamp'),
          thermalValue: 3,
          batteryLevel: 50.0,
          memoryUsage: 50.0,
        ),
      ).called(1);
    });

    test('clamps batteryLevel and memoryUsage to 0–100', () async {
      when(
        () => mockDeviceRepository.getDeviceInfo(),
      ).thenAnswer((_) async => const DeviceInfo('dev-1'));
      when(
        () => mockVitalsRepository.logVital(
          deviceId: any(named: 'deviceId'),
          timestamp: any(named: 'timestamp'),
          thermalValue: any(named: 'thermalValue'),
          batteryLevel: any(named: 'batteryLevel'),
          memoryUsage: any(named: 'memoryUsage'),
        ),
      ).thenAnswer((_) async {});

      await usecase.call(
        thermalValue: 0,
        batteryLevel: 150.0,
        memoryUsage: -10.0,
      );

      verify(
        () => mockVitalsRepository.logVital(
          deviceId: 'dev-1',
          timestamp: any(named: 'timestamp'),
          thermalValue: 0,
          batteryLevel: 100.0,
          memoryUsage: 0.0,
        ),
      ).called(1);
    });

    test('propagates exception from getDeviceInfo', () async {
      when(
        () => mockDeviceRepository.getDeviceInfo(),
      ).thenThrow(Exception('Device unavailable'));

      expect(
        () => usecase.call(
          thermalValue: 1,
          batteryLevel: 50.0,
          memoryUsage: 50.0,
        ),
        throwsA(isA<Exception>()),
      );

      verifyNever(
        () => mockVitalsRepository.logVital(
          deviceId: any(named: 'deviceId'),
          timestamp: any(named: 'timestamp'),
          thermalValue: any(named: 'thermalValue'),
          batteryLevel: any(named: 'batteryLevel'),
          memoryUsage: any(named: 'memoryUsage'),
        ),
      );
    });

    test('propagates exception from logVital', () async {
      when(
        () => mockDeviceRepository.getDeviceInfo(),
      ).thenAnswer((_) async => const DeviceInfo('dev-1'));
      when(
        () => mockVitalsRepository.logVital(
          deviceId: any(named: 'deviceId'),
          timestamp: any(named: 'timestamp'),
          thermalValue: any(named: 'thermalValue'),
          batteryLevel: any(named: 'batteryLevel'),
          memoryUsage: any(named: 'memoryUsage'),
        ),
      ).thenThrow(Exception('Network error'));

      expect(
        () => usecase.call(
          thermalValue: 1,
          batteryLevel: 50.0,
          memoryUsage: 50.0,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
