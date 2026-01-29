part of 'locale_bloc.dart';

final class LocaleState extends Equatable {
  const LocaleState({this.locale});
  final Locale? locale;

  LocaleState copyWith({Locale? locale}) {
    return LocaleState(locale: locale ?? this.locale);
  }

  @override
  List<Object?> get props => [locale];
}
