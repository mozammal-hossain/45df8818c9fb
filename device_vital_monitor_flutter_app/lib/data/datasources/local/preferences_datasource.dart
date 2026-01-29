import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:device_vital_monitor_flutter_app/core/utils/constants.dart';

@lazySingleton
class PreferencesDatasource {
  PreferencesDatasource(this._prefs);

  final SharedPreferences _prefs;

  Future<ThemeMode> getThemeMode() async {
    final raw = _prefs.getString(Constants.themeModeKey);
    if (raw == null) return ThemeMode.system;
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(Constants.themeModeKey, mode.name);
  }

  Future<Locale?> getLocale() async {
    final code = _prefs.getString(Constants.localeKey);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(Constants.localeKey);
    } else {
      await _prefs.setString(Constants.localeKey, locale.languageCode);
    }
  }

  Future<bool> getAutoLoggingEnabled() async {
    return _prefs.getBool(Constants.autoLoggingEnabledKey) ?? false;
  }

  Future<void> setAutoLoggingEnabled(bool enabled) async {
    await _prefs.setBool(Constants.autoLoggingEnabledKey, enabled);
  }
}
