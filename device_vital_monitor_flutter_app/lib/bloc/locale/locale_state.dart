part of 'locale_bloc.dart';

/// {@template locale_state}
/// State for app locale. [locale] null means follow system.
/// {@endtemplate}
final class LocaleState extends Equatable {
  /// {@macro locale_state}
  const LocaleState({this.locale});

  /// Override locale; null = use system locale.
  final Locale? locale;

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale: locale ?? this.locale);
  }

  @override
  List<Object?> get props => [locale];
}
