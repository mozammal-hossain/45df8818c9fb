/// Shared extension methods.
extension NumRounding on num {
  /// Clamp to [lower] and [upper] and return as int.
  int clampInt(int lower, int upper) =>
      clamp(lower, upper).toInt();
}
