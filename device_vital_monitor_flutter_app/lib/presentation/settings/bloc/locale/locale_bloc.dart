import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:device_vital_monitor_flutter_app/domain/repositories/preferences_repository.dart';

part 'locale_event.dart';
part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc(this._preferences, {Locale? initial})
    : super(LocaleState(locale: initial)) {
    on<LocaleChanged>(_onLocaleChanged);
  }

  final PreferencesRepository _preferences;

  Future<void> _onLocaleChanged(
    LocaleChanged event,
    Emitter<LocaleState> emit,
  ) async {
    if (state.locale == event.locale) return;
    emit(LocaleState(locale: event.locale));
    await _preferences.setLocale(event.locale);
  }

  static Future<Locale?> loadLocale(PreferencesRepository preferences) {
    return preferences.getLocale();
  }
}
