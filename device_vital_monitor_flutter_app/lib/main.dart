import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/theme_provider_scope.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final mode = await ThemeProvider.loadThemeMode();
  runApp(MyApp(initialThemeMode: mode));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialThemeMode});

  final ThemeMode initialThemeMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider(initial: widget.initialThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProviderScope(
      provider: _themeProvider,
      child: ListenableBuilder(
        listenable: _themeProvider,
        builder: (context, _) => MaterialApp(
          title: 'Device Vital Monitor',
          theme: AppTheme.buildLightTheme(),
          darkTheme: AppTheme.buildDarkTheme(),
          themeMode: _themeProvider.mode,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const DashboardScreen(),
        ),
      ),
    );
  }
}
