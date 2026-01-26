import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

const String _themeModeKey = 'theme_mode';

/// Bloc for managing theme state
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({ThemeMode initial = ThemeMode.system})
      : super(ThemeInitial(initial)) {
    on<ThemeCycleRequested>(_onThemeCycleRequested);
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<ThemeModeLoaded>(_onThemeModeLoaded);
  }

  /// Current theme mode
  ThemeMode get currentMode {
    return switch (state) {
      ThemeInitial(mode: final mode) => mode,
      ThemeModeUpdated(mode: final mode) => mode,
    };
  }

  Future<void> _onThemeCycleRequested(
    ThemeCycleRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final current = currentMode;
    final nextMode = switch (current) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    emit(ThemeModeUpdated(nextMode));
    await _persist(nextMode);
  }

  Future<void> _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    if (currentMode == event.mode) return;
    emit(ThemeModeUpdated(event.mode));
    await _persist(event.mode);
  }

  void _onThemeModeLoaded(
    ThemeModeLoaded event,
    Emitter<ThemeState> emit,
  ) {
    emit(ThemeInitial(event.mode));
  }

  Future<void> _persist(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
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
