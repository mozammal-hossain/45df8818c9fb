/// Breakpoint constants for responsive layout.
///
/// Use with [MediaQuery.sizeOf] to switch layouts (e.g. column vs grid).
abstract final class Breakpoints {
  Breakpoints._();

  /// Mobile: width < 600.
  static const double mobile = 600;

  /// Tablet: 600 <= width < 840.
  static const double tablet = 840;

  /// Desktop: width >= 840.
  static const double desktop = 840;

  /// Wide: width >= 1200 (optional for large desktops).
  static const double wide = 1200;
}
