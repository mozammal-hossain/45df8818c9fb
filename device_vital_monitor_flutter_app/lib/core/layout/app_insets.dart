import 'package:flutter/material.dart';

import 'responsive.dart';

const double _baseWidth = 360;

/// Scale factor from [MediaQuery.sizeOf].width: min(1.2, width / _baseWidth).
/// Clamped so spacing grows slightly on larger screens but stays readable.
double _scaleFactor(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  final raw = w / _baseWidth;
  return raw.clamp(0.85, 1.2);
}

/// Base spacing values (logical px) before scaling.
abstract final class _Base {
  static const double xs = 4;
  static const double s = 8;
  static const double sm = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double page = 16;
  static const double card = 20;
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double iconS = 20;
  static const double iconM = 32;
  static const double iconL = 48;
  static const double iconXL = 64;
  static const double iconContainer = 56;
  static const double chartSize = 80;
  static const double progressHeight = 8;
  static const double minTouchTarget = 48;
  static const double settingsMaxWidth = 600;
}

/// Scalable insets and dimensions. Use these instead of hardcoded values.
abstract final class AppInsets {
  AppInsets._();

  static double _scale(BuildContext context, double value) =>
      value * _scaleFactor(context);

  /// XS spacing (e.g. 4).
  static double spacingXS(BuildContext context) => _scale(context, _Base.xs);

  /// S spacing (e.g. 8).
  static double spacingS(BuildContext context) => _scale(context, _Base.s);

  /// SM spacing (e.g. 12).
  static double spacingSM(BuildContext context) => _scale(context, _Base.sm);

  /// M spacing (e.g. 16).
  static double spacingM(BuildContext context) => _scale(context, _Base.m);

  /// L spacing (e.g. 24).
  static double spacingL(BuildContext context) => _scale(context, _Base.l);

  /// XL spacing (e.g. 32).
  static double spacingXL(BuildContext context) => _scale(context, _Base.xl);

  /// XXL spacing (e.g. 48).
  static double spacingXXL(BuildContext context) => _scale(context, _Base.xxl);

  /// Page padding (horizontal and vertical).
  static EdgeInsets pagePadding(BuildContext context) {
    final p = _scale(context, _Base.page);
    return EdgeInsets.all(p);
  }

  /// Card inner padding.
  static double cardPaddingValue(BuildContext context) =>
      _scale(context, _Base.card);

  static EdgeInsets cardPadding(BuildContext context) {
    final p = cardPaddingValue(context);
    return EdgeInsets.all(p);
  }

  /// Border radius S/M/L.
  static double radiusS(BuildContext context) =>
      _scale(context, _Base.radiusS);

  static double radiusM(BuildContext context) =>
      _scale(context, _Base.radiusM);

  static double radiusL(BuildContext context) =>
      _scale(context, _Base.radiusL);

  /// Icon sizes. Prefer these for consistency.
  static double iconS(BuildContext context) => _scale(context, _Base.iconS);

  static double iconM(BuildContext context) => _scale(context, _Base.iconM);

  static double iconL(BuildContext context) => _scale(context, _Base.iconL);

  static double iconXL(BuildContext context) => _scale(context, _Base.iconXL);

  /// Icon container (e.g. card header icon). ≥ 48 for touch.
  static double iconContainer(BuildContext context) =>
      _scale(context, _Base.iconContainer).clamp(_Base.minTouchTarget, double.infinity);

  /// Chart/circle size (e.g. memory circular progress).
  static double chartSize(BuildContext context) =>
      _scale(context, _Base.chartSize);

  /// Min touch target (≥ 48). Use for buttons, list tiles.
  static double minTouchTarget(BuildContext context) =>
      _scale(context, _Base.minTouchTarget).clamp(_Base.minTouchTarget, double.infinity);

  /// Progress bar height.
  static double progressHeight(BuildContext context) =>
      _scale(context, _Base.progressHeight);

  /// Max content width for settings (and similar) on wide screens.
  static double settingsMaxWidth(BuildContext context) =>
      _Base.settingsMaxWidth;

  /// Load-more threshold as fraction of viewport height (e.g. 0.15).
  static double loadMoreThresholdFraction(BuildContext context) => 0.15;

  static double loadMoreThreshold(BuildContext context) {
    final h = screenHeight(context);
    return (h * loadMoreThresholdFraction(context)).clamp(120, 300);
  }
}
