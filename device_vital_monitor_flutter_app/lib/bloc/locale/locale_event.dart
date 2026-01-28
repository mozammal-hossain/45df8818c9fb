part of 'locale_bloc.dart';

/// {@template locale_event}
/// Base class for locale events.
/// {@endtemplate}
sealed class LocaleEvent extends Equatable {
  /// {@macro locale_event}
  const LocaleEvent();

  @override
  List<Object?> get props => [];
}

/// {@template locale_changed}
/// Event to set the app locale. Pass null to follow system.
/// {@endtemplate}
final class LocaleChanged extends LocaleEvent {
  /// {@macro locale_changed}
  const LocaleChanged(this.locale);

  /// The locale to use, or null for system default.
  final Locale? locale;

  @override
  List<Object?> get props => [locale];
}
