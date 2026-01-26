import 'package:flutter/material.dart';

import 'theme_provider.dart';

/// Provides [ThemeProvider] to descendants.
///
/// Use [ThemeProviderScope.of] to obtain the provider and call
/// [ThemeProvider.cycleThemeMode] or [ThemeProvider.setThemeMode].
class ThemeProviderScope extends InheritedWidget {
  const ThemeProviderScope({
    super.key,
    required this.provider,
    required super.child,
  });

  final ThemeProvider provider;

  static ThemeProvider of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ThemeProviderScope>();
    assert(scope != null, 'ThemeProviderScope not found above context');
    return scope!.provider;
  }

  @override
  bool updateShouldNotify(ThemeProviderScope oldWidget) =>
      provider != oldWidget.provider;
}
