// Basic Flutter widget smoke test for Device Vital Monitor.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:device_vital_monitor_flutter_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('device_vital_monitor/sensors');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          if (call.method == 'getThermalState') return 0;
          if (call.method == 'getBatteryLevel') return 80;
          if (call.method == 'getBatteryHealth') return 'GOOD';
          if (call.method == 'getChargerConnection') return 'NONE';
          if (call.method == 'getBatteryStatus') return 'DISCHARGING';
          if (call.method == 'getMemoryUsage') return 50;
          if (call.method == 'getStorageInfo') {
            return <String, int>{
              'total': 64 * 1024 * 1024 * 1024,
              'used': 32 * 1024 * 1024 * 1024,
              'available': 32 * 1024 * 1024 * 1024,
              'usagePercent': 50,
            };
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(initialThemeMode: ThemeMode.system));
    await tester.pumpAndSettle();

    expect(find.text('Device Vital Monitor'), findsOneWidget);
  });
}
