import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/dashboard/dashboard_bloc.dart';
import 'bloc/theme/theme_bloc.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/injection/injection.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up BlocObserver for logging
  Bloc.observer = const AppBlocObserver();

  // Initialize dependency injection
  configureDependencies();

  // Load theme mode and create bloc
  final mode = await ThemeBloc.loadThemeMode();
  final themeBloc = ThemeBloc(initial: mode);

  // Get DashboardBloc from dependency injection
  final dashboardBloc = getIt<DashboardBloc>();

  runApp(MyApp(
    themeBloc: themeBloc,
    dashboardBloc: dashboardBloc,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.themeBloc,
    required this.dashboardBloc,
  });

  final ThemeBloc themeBloc;
  final DashboardBloc dashboardBloc;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>.value(value: themeBloc),
        BlocProvider<DashboardBloc>.value(value: dashboardBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Device Vital Monitor',
            theme: AppTheme.buildLightTheme(),
            darkTheme: AppTheme.buildDarkTheme(),
            themeMode: state.mode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
