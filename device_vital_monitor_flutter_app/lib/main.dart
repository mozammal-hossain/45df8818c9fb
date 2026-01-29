import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:device_vital_monitor_flutter_app/core/di/injection.dart';
import 'package:device_vital_monitor_flutter_app/core/theme/app_theme.dart';
import 'package:device_vital_monitor_flutter_app/l10n/app_localizations.dart';
import 'package:device_vital_monitor_flutter_app/domain/repositories/preferences_repository.dart';
import 'package:device_vital_monitor_flutter_app/presentation/common/bloc/app_bloc_observer.dart';
import 'package:device_vital_monitor_flutter_app/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/dashboard/dashboard_page.dart';
import 'package:device_vital_monitor_flutter_app/presentation/settings/bloc/locale/locale_bloc.dart';
import 'package:device_vital_monitor_flutter_app/presentation/settings/bloc/theme/theme_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = const AppBlocObserver();

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  configureDependencies();

  final preferencesRepo = getIt<PreferencesRepository>();
  final mode = await ThemeBloc.loadThemeMode(preferencesRepo);
  final themeBloc = ThemeBloc(preferencesRepo, initial: mode);
  final locale = await LocaleBloc.loadLocale(preferencesRepo);
  final localeBloc = LocaleBloc(preferencesRepo, initial: locale);

  final dashboardBloc = getIt<DashboardBloc>();

  runApp(MyApp(
    themeBloc: themeBloc,
    localeBloc: localeBloc,
    dashboardBloc: dashboardBloc,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.themeBloc,
    required this.localeBloc,
    required this.dashboardBloc,
  });

  final ThemeBloc themeBloc;
  final LocaleBloc localeBloc;
  final DashboardBloc dashboardBloc;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>.value(value: themeBloc),
        BlocProvider<LocaleBloc>.value(value: localeBloc),
        BlocProvider<DashboardBloc>.value(value: dashboardBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp(
                title: 'Device Vital Monitor',
                theme: AppTheme.buildLightTheme(),
                darkTheme: AppTheme.buildDarkTheme(),
                themeMode: themeState.mode,
                locale: localeState.locale,
                localizationsDelegates:
                    AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const DashboardPage(),
              );
            },
          );
        },
      ),
    );
  }
}
