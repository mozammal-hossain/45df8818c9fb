import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_event.dart';
part 'locale_state.dart';

const String _localeKey = 'app_locale';

/// {@template locale_bloc}
/// Bloc for managing app locale. [LocaleState.locale] null means system default.
/// {@endtemplate}
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  /// {@macro locale_bloc}
  LocaleBloc({Locale? initial}) : super(LocaleState(locale: initial)) {
    on<LocaleChanged>(_onLocaleChanged);
  }

  Future<void> _onLocaleChanged(
    LocaleChanged event,
    Emitter<LocaleState> emit,
  ) async {
    if (state.locale == event.locale) return;
    emit(LocaleState(locale: event.locale));
    await _persist(event.locale);
  }

  Future<void> _persist(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
  }

  /// Loads saved locale from [SharedPreferences].
  static Future<Locale?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }
}
