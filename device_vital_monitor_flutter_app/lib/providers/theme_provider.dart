import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeModeKey = 'theme_mode';

/// Holds [ThemeMode] and persists it via [SharedPreferences].
///
/// Defaults to [ThemeMode.system]. Use [cycleThemeMode] to toggle
/// light → dark → system.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({ThemeMode initial = ThemeMode.system}) : _mode = initial;

  ThemeMode _mode;

  ThemeMode get mode => _mode;

  /// Cycles theme: light → dark → system → light.
  Future<void> cycleThemeMode() async {
    switch (_mode) {
      case ThemeMode.light:
        _mode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _mode = ThemeMode.system;
        break;
      case ThemeMode.system:
        _mode = ThemeMode.light;
        break;
    }
    notifyListeners();
    await _persist();
  }

  /// Sets [ThemeMode] and persists.
  Future<void> setThemeMode(ThemeMode value) async {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _mode.name);
  }

  /// Loads saved [ThemeMode] from [SharedPreferences].
  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    if (raw == null) return ThemeMode.system;
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
