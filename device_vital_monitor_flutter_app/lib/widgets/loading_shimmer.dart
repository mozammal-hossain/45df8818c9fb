import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays a shimmering loading effect.
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
    super.key,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use theme-aware colors for shimmer
    final baseColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : Colors.grey[300]!;
    final highlightColor = isDark
        ? theme.colorScheme.surfaceContainer
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors
              .black, // The color here doesn't matter, it's just a mask for the shimmer
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? (borderRadius ?? BorderRadius.circular(8))
              : null,
        ),
      ),
    );
  }
}
