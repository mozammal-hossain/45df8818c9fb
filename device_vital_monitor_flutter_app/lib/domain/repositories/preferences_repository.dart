import 'package:flutter/material.dart';

/// Abstract preferences repository: theme and locale.
abstract interface class PreferencesRepository {
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Future<Locale?> getLocale();
  Future<void> setLocale(Locale? locale);
}
