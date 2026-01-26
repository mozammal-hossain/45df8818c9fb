import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/theme/theme_bloc.dart';
import 'core/injection/injection.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  configureDependencies();
  
  // Load theme mode and create bloc
  final mode = await ThemeBloc.loadThemeMode();
  final themeBloc = ThemeBloc(initial: mode);
  
  runApp(MyApp(themeBloc: themeBloc));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.themeBloc});

  final ThemeBloc themeBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>.value(
      value: themeBloc,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final themeMode = switch (state) {
            ThemeInitial(mode: final mode) => mode,
            ThemeModeUpdated(mode: final mode) => mode,
          };
          
          return MaterialApp(
            title: 'Device Vital Monitor',
            theme: AppTheme.buildLightTheme(),
            darkTheme: AppTheme.buildDarkTheme(),
            themeMode: themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
