import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/domain/repositories/preferences_repository.dart';
import 'package:device_vital_monitor_flutter_app/data/datasources/local/preferences_datasource.dart';

@LazySingleton(as: PreferencesRepository)
class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl(this._prefs);

  final PreferencesDatasource _prefs;

  @override
  Future<ThemeMode> getThemeMode() => _prefs.getThemeMode();

  @override
  Future<void> setThemeMode(ThemeMode mode) => _prefs.setThemeMode(mode);

  @override
  Future<Locale?> getLocale() => _prefs.getLocale();

  @override
  Future<void> setLocale(Locale? locale) => _prefs.setLocale(locale);
}
