import '../models/player.dart';
import '../models/match_state.dart';

class RatingEngine {
  /// Calculate rating for a single player
  static double calculatePlayerRating(Player player, PlayerMatchStats stats) {
    double rating = 6.0; // Base match rating

    // ---------------- OFFENSIVE ----------------
    rating += stats.goals * 1.2;
    rating += stats.assists * 0.8;
    rating += stats.shotsOnTarget * 0.15;

    // ---------------- BUILD-UP ----------------
    rating += (stats.passesCompleted / 20);
    rating += (stats.dribblesCompleted * 0.2);

    // ---------------- DEFENSIVE ----------------
    rating += (stats.tackles * 0.15);
    rating += (stats.interceptions * 0.15);

    // ---------------- DISCIPLINE ----------------
    rating -= stats.fouls * 0.1;
    rating -= stats.yellowCards * 0.5;
    rating -= stats.redCards * 1.5;

    // ---------------- GOALKEEPER ----------------
    if (player.position == "GK") {
      rating += stats.saves * 0.25;
      rating -= stats.goalsConceded * 0.7;
    }

    // ---------------- FITNESS ----------------
    rating -= (player.fatigue / 120);

    // ---------------- MINUTES PLAYED ----------------
    if (stats.minutesPlayed < 30) rating -= 0.5;
    if (stats.minutesPlayed > 80) rating += 0.2;

    return rating.clamp(4.0, 9.8);
  }

  /// Calculate ratings for all players
  static void calculateAll(MatchState match) {
    for (final entry in match.playerStats.entries) {
      final player = entry.key;
      final stats = entry.value;
      stats.rating = calculatePlayerRating(player, stats);
    }
  }

  /// Pick Man of the Match
  static Player selectManOfTheMatch(MatchState match) {
    return match.playerStats.values.reduce((a, b) {
      if (a.rating != b.rating) {
        return a.rating > b.rating ? a : b;
      }
      return a.motmPoints > b.motmPoints ? a : b;
    }).player;
  }
}
