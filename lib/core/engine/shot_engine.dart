import 'dart:math';
import '../models/player.dart';

class ShotResult {
  final bool goal;
  final bool saved;
  final bool blocked;

  ShotResult({required this.goal, required this.saved, required this.blocked});
}

class ShotEngine {
  static final Random _rng = Random();

  /// Resolve a shot between shooter and goalkeeper
  static ShotResult takeShot({
    required Player shooter,
    required Player goalkeeper,

    /// Defensive & situational modifiers (passed from possession engine)
    double difficultyMultiplier = 1.0,
    double fatigueEffect = 1.0,
    double pressure = 1.0,
  }) {
    // ------------------------------------------------------------
    // SHOOTER POWER & ACCURACY
    // ------------------------------------------------------------
    double shotQuality =
        shooter.shooting * 0.45 +
        shooter.technique * 0.25 +
        shooter.intelligence * 0.15 +
        shooter.form * 0.15;

    shotQuality *= fatigueEffect;
    shotQuality *= (shooter.morale / 100);
    shotQuality *= difficultyMultiplier;

    // Slight randomness (max ~8%)
    shotQuality *= 0.92 + _rng.nextDouble() * 0.08;

    // ------------------------------------------------------------
    // GOALKEEPER RESPONSE
    // ------------------------------------------------------------
    double keeperStrength =
        goalkeeper.reflexes * 0.45 +
        goalkeeper.handling * 0.35 +
        goalkeeper.form * 0.2;

    keeperStrength *= pressure;
    keeperStrength *= (1 - goalkeeper.fatigue / 120);

    // Slight randomness
    keeperStrength *= 0.92 + _rng.nextDouble() * 0.08;

    // ------------------------------------------------------------
    // BLOCK CHANCE (DEFENDERS)
    // ------------------------------------------------------------
    double blockChance = (pressure * 30).clamp(5, 40); // %
    bool blocked = _rng.nextDouble() * 100 < blockChance;

    if (blocked) {
      return ShotResult(goal: false, saved: false, blocked: true);
    }

    // ------------------------------------------------------------
    // FINAL DECISION
    // ------------------------------------------------------------
    if (shotQuality > keeperStrength) {
      return ShotResult(goal: true, saved: false, blocked: false);
    } else {
      return ShotResult(goal: false, saved: true, blocked: false);
    }
  }
}
