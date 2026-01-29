import 'package:flutter/material.dart';

/// Centralized text style builders for the app theme.
abstract final class TextStyles {
  TextStyles._();

  /// Builds a [TextTheme] for the given [baseColor].
  static TextTheme buildTextTheme(Color baseColor) {
    final onSurfaceVariant = baseColor.withValues(alpha: 0.7);
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: baseColor, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, color: baseColor, height: 1.4),
      bodySmall: TextStyle(fontSize: 13, color: onSurfaceVariant, height: 1.4),
      labelLarge: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
      ),
    );
  }
}
