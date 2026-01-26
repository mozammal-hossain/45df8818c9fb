import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_event.dart';
part 'theme_state.dart';

const String _themeModeKey = 'theme_mode';

/// {@template theme_bloc}
/// Bloc for managing theme state.
/// {@endtemplate}
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  /// {@macro theme_bloc}
  ThemeBloc({ThemeMode initial = ThemeMode.system})
      : super(ThemeState(mode: initial)) {
    on<ThemeCycleRequested>(_onThemeCycleRequested);
    on<ThemeModeChanged>(_onThemeModeChanged);
  }

  /// Current theme mode
  ThemeMode get currentMode => state.mode;

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
    emit(state.copyWith(mode: nextMode));
    await _persist(nextMode);
  }

  Future<void> _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    if (currentMode == event.mode) return;
    emit(state.copyWith(mode: event.mode));
    await _persist(event.mode);
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
