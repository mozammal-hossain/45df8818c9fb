import 'package:flutter/material.dart';

/// Design tokens for semantic status and surface colors.
///
/// Use [Theme.of(context).extension<AppColors>()] to access. All colors
/// are defined in a common place and adapt to light/dark theme.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.warning,
    required this.low,
    required this.error,
    required this.onStatus,
    required this.surfaceContainer,
    required this.surfaceContainerLow,
    required this.iconTint,
    required this.progressTrack,
  });

  /// Green – healthy/optimized state (e.g. battery ≥80%, thermal none).
  final Color success;

  /// Orange – moderate state (e.g. battery 50–79%, thermal light).
  final Color warning;

  /// Deep orange – low state (e.g. battery 20–49%, thermal moderate).
  final Color low;

  /// Red – critical/error state (e.g. battery &lt;20%, thermal severe).
  final Color error;

  /// Text color on status-colored backgrounds (badges, etc.).
  final Color onStatus;

  /// Card and elevated surface background.
  final Color surfaceContainer;

  /// Muted container (e.g. icon chips, secondary surfaces).
  final Color surfaceContainerLow;

  /// App bar and list icon tint.
  final Color iconTint;

  /// Progress bar and circular progress track (background).
  final Color progressTrack;

  @override
  ThemeExtension<AppColors> copyWith({
    Color? success,
    Color? warning,
    Color? low,
    Color? error,
    Color? onStatus,
    Color? surfaceContainer,
    Color? surfaceContainerLow,
    Color? iconTint,
    Color? progressTrack,
  }) {
    return AppColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      low: low ?? this.low,
      error: error ?? this.error,
      onStatus: onStatus ?? this.onStatus,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      iconTint: iconTint ?? this.iconTint,
      progressTrack: progressTrack ?? this.progressTrack,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      low: Color.lerp(low, other.low, t)!,
      error: Color.lerp(error, other.error, t)!,
      onStatus: Color.lerp(onStatus, other.onStatus, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceContainerLow: Color.lerp(
        surfaceContainerLow,
        other.surfaceContainerLow,
        t,
      )!,
      iconTint: Color.lerp(iconTint, other.iconTint, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
    );
  }

  /// Light theme design tokens.
  static const AppColors light = AppColors(
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    low: Color(0xFFFF5722),
    error: Color(0xFFD32F2F),
    onStatus: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFE3F2FD),
    iconTint: Color(0xFF212121),
    progressTrack: Color(0xFFE0E0E0),
  );

  /// Dark theme design tokens.
  static const AppColors dark = AppColors(
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    low: Color(0xFFFF8A65),
    error: Color(0xFFEF5350),
    onStatus: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFF2C2C2E),
    surfaceContainerLow: Color(0xFF1E3A5F),
    iconTint: Color(0xFFE0E0E0),
    progressTrack: Color(0xFF424242),
  );
}
