part of 'theme_bloc.dart';

/// {@template theme_event}
/// Base class for all theme events.
/// {@endtemplate}
sealed class ThemeEvent extends Equatable {
  /// {@macro theme_event}
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// {@template theme_cycle_requested}
/// Event to cycle through theme modes: light → dark → system → light.
/// {@endtemplate}
final class ThemeCycleRequested extends ThemeEvent {
  /// {@macro theme_cycle_requested}
  const ThemeCycleRequested();
}

/// {@template theme_mode_changed}
/// Event to set a specific theme mode.
/// {@endtemplate}
final class ThemeModeChanged extends ThemeEvent {
  /// {@macro theme_mode_changed}
  const ThemeModeChanged(this.mode);

  final ThemeMode mode;

  @override
  List<Object?> get props => [mode];
}
