import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:device_vital_monitor_flutter_app/domain/repositories/preferences_repository.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc(this._preferences, {ThemeMode initial = ThemeMode.system})
      : super(ThemeState(mode: initial)) {
    on<ThemeCycleRequested>(_onThemeCycleRequested);
    on<ThemeModeChanged>(_onThemeModeChanged);
  }

  final PreferencesRepository _preferences;

  ThemeMode get currentMode => state.mode;

  Future<void> _onThemeCycleRequested(
    ThemeCycleRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final nextMode = switch (currentMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    emit(state.copyWith(mode: nextMode));
    await _preferences.setThemeMode(nextMode);
  }

  Future<void> _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    if (currentMode == event.mode) return;
    emit(state.copyWith(mode: event.mode));
    await _preferences.setThemeMode(event.mode);
  }

  static Future<ThemeMode> loadThemeMode(PreferencesRepository preferences) {
    return preferences.getThemeMode();
  }
}
