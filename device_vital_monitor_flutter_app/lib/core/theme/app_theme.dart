import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'text_styles.dart';

/// Centralized theme configuration.
///
/// All colors and component styles are defined here. Use [buildLightTheme]
/// and [buildDarkTheme] for [MaterialApp.theme] and [MaterialApp.darkTheme].
abstract final class AppTheme {
  AppTheme._();

  static const Color _seedColor = Color(0xFF1976D2);

  /// Light theme using Material 3 and [AppColors.light].
  static ThemeData buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );
    final textTheme = TextStyles.buildTextTheme(AppColors.light.iconTint);
    final iconTint = AppColors.light.iconTint;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: const <ThemeExtension<dynamic>>[AppColors.light],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: iconTint,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge!.copyWith(color: iconTint),
        iconTheme: IconThemeData(color: iconTint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.light.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      textTheme: textTheme,
    );
  }

  /// Dark theme using Material 3 and [AppColors.dark].
  static ThemeData buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    );
    final textTheme = TextStyles.buildTextTheme(AppColors.dark.iconTint);
    final iconTint = AppColors.dark.iconTint;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: const <ThemeExtension<dynamic>>[AppColors.dark],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: iconTint,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge!.copyWith(color: iconTint),
        iconTheme: IconThemeData(color: iconTint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.dark.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      textTheme: textTheme,
    );
  }

}
