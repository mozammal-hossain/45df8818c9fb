part of 'theme_bloc.dart';

/// State for theme management
sealed class ThemeState {
  const ThemeState();
}

/// Initial state with the current theme mode
class ThemeInitial extends ThemeState {
  const ThemeInitial(this.mode);
  final ThemeMode mode;
}

/// State when theme mode has changed
class ThemeModeUpdated extends ThemeState {
  const ThemeModeUpdated(this.mode);
  final ThemeMode mode;
}
