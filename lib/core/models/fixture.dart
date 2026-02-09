import 'dart:math';
import 'team.dart';

/// Represents a single match fixture
class Fixture {
  final Team home;
  final Team away;
  final int week; // Matchweek number
  final int day; // 1 = Monday, 7 = Sunday

  int? homeGoals;
  int? awayGoals;
  bool played;

  Fixture({
    required this.home,
    required this.away,
    required this.week,
    required this.day,
    this.homeGoals,
    this.awayGoals,
    this.played = false,
  });

  /// Play or simulate this fixture
  void play({int? homeScore, int? awayScore}) {
    if (played) return;

    final rand = Random();

    // Use team strength instead of non-existing averageSkill
    final homeStrength = home.calculateTeamStrength();
    final awayStrength = away.calculateTeamStrength();

    homeGoals = homeScore ?? _simulateGoals(homeStrength, awayStrength, rand);
    awayGoals = awayScore ?? _simulateGoals(awayStrength, homeStrength, rand);

    // Update teams using EXISTING method
    home.updateMatchResult(goalsFor: homeGoals!, goalsAgainst: awayGoals!);

    away.updateMatchResult(goalsFor: awayGoals!, goalsAgainst: homeGoals!);

    played = true;
  }

  /// Simple FM-style goal simulation
  int _simulateGoals(double attack, double defense, Random rand) {
    double base = 1.2 + (attack - defense) / 40;
    base = base.clamp(0.2, 4.0);
    return rand.nextInt(base.ceil() + 1);
  }

  /// Whether this is the next match for a team
  bool isNextMatch(Team team) {
    return !played && (home == team || away == team);
  }

  @override
  String toString() {
    if (played) {
      return "${home.name} $homeGoals - $awayGoals ${away.name}";
    }
    return "${home.name} vs ${away.name} (Week $week, Day $day)";
  }
}
