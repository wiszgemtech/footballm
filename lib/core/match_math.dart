import 'dart:math';

class MatchMath {
  static final Random _rng = Random();

  /// Returns true based on a percentage chance (0–100)
  static bool chance(double value) {
    // Ensure value is between 0 and 100
    final capped = value.clamp(0, 100);
    return _rng.nextDouble() * 100 < capped;
  }
}
