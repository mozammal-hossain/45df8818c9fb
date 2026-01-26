part of 'theme_bloc.dart';

/// {@template theme_state}
/// State for theme management.
/// {@endtemplate}
final class ThemeState extends Equatable {
  /// {@macro theme_state}
  const ThemeState({this.mode = ThemeMode.system});

  final ThemeMode mode;

  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }

  @override
  List<Object?> get props => [mode];
}
