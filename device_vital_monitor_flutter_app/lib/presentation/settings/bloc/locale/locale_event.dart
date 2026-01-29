part of 'locale_bloc.dart';

sealed class LocaleEvent extends Equatable {
  const LocaleEvent();
  @override
  List<Object?> get props => [];
}

final class LocaleChanged extends LocaleEvent {
  const LocaleChanged(this.locale);
  final Locale? locale;
  @override
  List<Object?> get props => [locale];
}
