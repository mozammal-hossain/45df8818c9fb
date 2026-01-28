import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_vital_monitor_flutter_app/data/datasources/platform/sensor_platform_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SensorPlatformDatasource - Memory Usage Tests', () {
    const MethodChannel channel = MethodChannel('device_vital_monitor/sensors');
    late SensorPlatformDatasource service;

    setUp(() {
      service = SensorPlatformDatasource();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    group('getMemoryUsage - Success Cases', () {
      test('should return memory usage percentage when successful', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 45;
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, equals(45));
      });

      test('should return 0% memory usage', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 0;
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, equals(0));
      });

      test('should return 100% memory usage', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 100;
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, equals(100));
      });

      test('should return memory usage at critical threshold (90%)', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 90;
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, equals(90));
      });

      test('should return memory usage at high threshold (75%)', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 75;
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, equals(75));
      });

      test('should return memory usage at moderate threshold (50%)', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 50;
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, equals(50));
      });

      test('should return memory usage at normal threshold (25%)', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 25;
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, equals(25));
      });

      test('should return memory usage at optimized level (10%)', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 10;
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, equals(10));
      });

      test('should handle memory usage values between thresholds', () async {
        final testValues = [1, 24, 26, 49, 51, 74, 76, 89, 91, 99];

        for (final value in testValues) {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
                if (methodCall.method == 'getMemoryUsage') {
                  return value;
                }
                return null;
              });

          final result = await service.getMemoryUsage();
          expect(result, equals(value), reason: 'Failed for value: $value');
        }
      });
    });

    group('getMemoryUsage - Error Handling', () {
      test('should return null on PlatformException', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                throw PlatformException(
                  code: 'UNAVAILABLE',
                  message: 'Memory usage not available',
                );
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, isNull);
      });

      test('should return null on MissingPluginException', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                throw MissingPluginException('Method not implemented');
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, isNull);
      });

      test('should return null when method channel returns null', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return null;
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, isNull);
      });

      test('should handle generic exceptions gracefully', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                throw Exception('Unexpected error');
              }
              return null;
            });

        // The MethodChannel wraps generic exceptions as PlatformException,
        // so the service should return null
        final result = await service.getMemoryUsage();
        expect(result, isNull);
      });

      test(
        'should return null on PlatformException with PERMISSION_DENIED code',
        () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
                if (methodCall.method == 'getMemoryUsage') {
                  throw PlatformException(
                    code: 'PERMISSION_DENIED',
                    message: 'Permission denied',
                  );
                }
                return null;
              });

          final result = await service.getMemoryUsage();

          expect(result, isNull);
        },
      );

      test(
        'should return null on PlatformException with NOT_IMPLEMENTED code',
        () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
                if (methodCall.method == 'getMemoryUsage') {
                  throw PlatformException(
                    code: 'NOT_IMPLEMENTED',
                    message: 'Method not implemented',
                  );
                }
                return null;
              });

          final result = await service.getMemoryUsage();

          expect(result, isNull);
        },
      );

      test(
        'should return null on PlatformException with TIMEOUT code',
        () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
                if (methodCall.method == 'getMemoryUsage') {
                  throw PlatformException(
                    code: 'TIMEOUT',
                    message: 'Operation timed out',
                  );
                }
                return null;
              });

          final result = await service.getMemoryUsage();

          expect(result, isNull);
        },
      );

      test(
        'should return null on PlatformException with UNKNOWN_ERROR code',
        () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
                if (methodCall.method == 'getMemoryUsage') {
                  throw PlatformException(
                    code: 'UNKNOWN_ERROR',
                    message: 'Unknown error occurred',
                  );
                }
                return null;
              });

          final result = await service.getMemoryUsage();

          expect(result, isNull);
        },
      );

      test(
        'should return null on PlatformException with null message',
        () async {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
                if (methodCall.method == 'getMemoryUsage') {
                  throw PlatformException(code: 'ERROR', message: null);
                }
                return null;
              });

          final result = await service.getMemoryUsage();

          expect(result, isNull);
        },
      );

      test('should return null on PlatformException with details', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                throw PlatformException(
                  code: 'ERROR',
                  message: 'Error with details',
                  details: {'errorCode': 123, 'errorType': 'memory'},
                );
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, isNull);
      });
    });

    group('getMemoryUsage - Type Validation', () {
      test('should handle integer values correctly', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 42; // Explicitly an int
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, isA<int>());
        expect(result, equals(42));
      });

      test('should handle large integer values', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 2147483647; // Max 32-bit int
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, isA<int>());
        expect(result, equals(2147483647));
      });

      test('should handle negative values', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return -10; // Invalid but service should handle it
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, isA<int>());
        expect(result, equals(-10));
      });

      test('should handle values greater than 100', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 150; // Invalid but service should handle it
              }
              return null;
            });

        final result = await service.getMemoryUsage();

        expect(result, isA<int>());
        expect(result, equals(150));
      });
    });

    group('getMemoryUsage - Concurrent Calls', () {
      test('should handle multiple concurrent calls', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                return 50;
              }
              return null;
            });

        final futures = List<Future<int?>>.generate(
          5,
          (_) => service.getMemoryUsage(),
        );

        final results = await Future.wait(futures);

        expect(results.length, equals(5));
        expect(results.every((r) => r == 50), isTrue);
      });
    });

    group('getMemoryUsage - Performance', () {
      test('should complete within reasonable time', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                await Future.delayed(const Duration(milliseconds: 10));
                return 50;
              }
              return null;
            });

        final stopwatch = Stopwatch()..start();
        await service.getMemoryUsage();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      test('should handle slow responses (100ms delay)', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                await Future.delayed(const Duration(milliseconds: 100));
                return 50;
              }
              return null;
            });

        final stopwatch = Stopwatch()..start();
        final result = await service.getMemoryUsage();
        stopwatch.stop();

        expect(result, equals(50));
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
      });

      test('should handle very slow responses (500ms delay)', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                await Future.delayed(const Duration(milliseconds: 500));
                return 50;
              }
              return null;
            });

        final stopwatch = Stopwatch()..start();
        final result = await service.getMemoryUsage();
        stopwatch.stop();

        expect(result, equals(50));
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(500));
        expect(stopwatch.elapsedMilliseconds, lessThan(600));
      });
    });

    group('getMemoryUsage - Rapid Successive Calls', () {
      test('should handle rapid successive calls', () async {
        int callCount = 0;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
              if (methodCall.method == 'getMemoryUsage') {
                callCount++;
                return callCount * 10; // Return different values
              }
              return null;
            });

        final futures = List<Future<int?>>.generate(
          10,
          (_) => service.getMemoryUsage(),
        );

        final results = await Future.wait(futures);

        expect(results.length, equals(10));
        expect(callCount, equals(10));
        // All should be valid integers
        expect(results.every((r) => r != null && r is int), isTrue);
      });
    });
  });
}
