part of 'theme_bloc.dart';

/// Base class for theme events
sealed class ThemeEvent {
  const ThemeEvent();
}

/// Event to cycle through theme modes: light → dark → system → light
class ThemeCycleRequested extends ThemeEvent {
  const ThemeCycleRequested();
}

/// Event to set a specific theme mode
class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.mode);
  final ThemeMode mode;
}

/// Event to load theme mode from persistence
class ThemeModeLoaded extends ThemeEvent {
  const ThemeModeLoaded(this.mode);
  final ThemeMode mode;
}
