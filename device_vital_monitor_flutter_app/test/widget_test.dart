// Basic Flutter widget smoke test for Device Vital Monitor.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:device_vital_monitor_flutter_app/core/di/injection.dart';
import 'package:device_vital_monitor_flutter_app/main.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/preferences_repository.dart';
import 'package:device_vital_monitor_flutter_app/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/settings/bloc/locale/locale_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/settings/bloc/theme/theme_bloc.dart';

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
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);
    configureDependencies();

    final preferencesRepo = getIt<PreferencesRepository>();
    final mode = await ThemeBloc.loadThemeMode(preferencesRepo);
    final themeBloc = ThemeBloc(preferencesRepo, initial: mode);
    final locale = await LocaleBloc.loadLocale(preferencesRepo);
    final localeBloc = LocaleBloc(preferencesRepo, initial: locale);
    final dashboardBloc = getIt<DashboardBloc>();

    await tester.pumpWidget(MyApp(
      themeBloc: themeBloc,
      localeBloc: localeBloc,
      dashboardBloc: dashboardBloc,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Device Vital Monitor'), findsOneWidget);
  });
}
