import 'package:flutter/material.dart';

import 'breakpoints.dart';

/// Current layout breakpoint based on shortest side (typically width).
enum LayoutBreakpoint {
  mobile,
  tablet,
  desktop,
  wide,
}

/// Returns the current [LayoutBreakpoint] for [context].
LayoutBreakpoint breakpointOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= Breakpoints.wide) return LayoutBreakpoint.wide;
  if (w >= Breakpoints.desktop) return LayoutBreakpoint.desktop;
  if (w >= Breakpoints.mobile) return LayoutBreakpoint.tablet;
  return LayoutBreakpoint.mobile;
}

/// Shortcut for [MediaQuery.sizeOf](context).width.
double screenWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width;

/// Shortcut for [MediaQuery.sizeOf](context).height.
double screenHeight(BuildContext context) =>
    MediaQuery.sizeOf(context).height;

/// True when width >= [Breakpoints.mobile] (tablet or larger).
bool isWideScreen(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= Breakpoints.mobile;

/// True when width >= [Breakpoints.desktop].
bool isDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

/// True when width >= [Breakpoints.wide].
bool isWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= Breakpoints.wide;

/// Number of grid columns for the current breakpoint (e.g. dashboard cards).
int gridColumns(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= Breakpoints.wide) return 3;
  if (w >= Breakpoints.desktop) return 3;
  if (w >= Breakpoints.mobile) return 2;
  return 1;
}

/// Builder that exposes [LayoutBreakpoint] and [width] to children.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  final Widget Function(
    BuildContext context,
    LayoutBreakpoint breakpoint,
    double width,
  ) builder;

  @override
  Widget build(BuildContext context) {
    final bp = breakpointOf(context);
    final w = screenWidth(context);
    return builder(context, bp, w);
  }
}
