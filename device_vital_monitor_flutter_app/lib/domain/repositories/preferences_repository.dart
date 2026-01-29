import 'package:flutter/material.dart';

/// Abstract preferences repository: theme, locale, and auto-logging.
abstract interface class PreferencesRepository {
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Future<Locale?> getLocale();
  Future<void> setLocale(Locale? locale);
  Future<bool> getAutoLoggingEnabled();
  Future<void> setAutoLoggingEnabled(bool enabled);
}
