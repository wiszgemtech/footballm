/// match.dart
/// Represents a single match fixture with full stats, results, and events.

import 'team.dart';
import 'player.dart';
import 'dart:math';

class Match {
  final Team home;
  final Team away;

  final int week;
  final int day; // 1 = Monday, 7 = Sunday

  int? homeGoals;
  int? awayGoals;

  bool played = false;

  // Events for the match: goals, cards, injuries, substitutions
  final List<String> events = [];

  // Track goal scorers and assists
  final Map<Player, int> goalScorers = {};
  final Map<Player, int> assists = {};

  Match({
    required this.home,
    required this.away,
    required this.week,
    required this.day,
    this.homeGoals,
    this.awayGoals,
    this.played = false,
  });

  /// Play the match: either simulate or use provided score
  void play({int? homeScore, int? awayScore}) {
    if (played) return;

    final rand = Random();

    homeGoals =
        homeScore ?? _simulateGoals(home.averageSkill, away.averageSkill, rand);
    awayGoals =
        awayScore ?? _simulateGoals(away.averageSkill, home.averageSkill, rand);

    // Update player stats randomly for goals
    _simulateGoalScorers(homeGoals!, awayGoals!, rand);

    // Update teams' stats
    home.updateStats(scored: homeGoals!, conceded: awayGoals!);
    away.updateStats(scored: awayGoals!, conceded: homeGoals!);

    played = true;
  }

  /// Simulate goal scorers and assists
  void _simulateGoalScorers(int homeGoals, int awayGoals, Random rand) {
    List<Player> homeAttackers = home.getStartingLineup();
    List<Player> awayAttackers = away.getStartingLineup();

    for (int i = 0; i < homeGoals; i++) {
      Player scorer = homeAttackers[rand.nextInt(homeAttackers.length)];
      goalScorers.update(scorer, (v) => v + 1, ifAbsent: () => 1);

      Player assist = homeAttackers[rand.nextInt(homeAttackers.length)];
      assists.update(assist, (v) => v + 1, ifAbsent: () => 1);

      events.add(
        "Goal for ${home.name}: ${scorer.name} (assisted by ${assist.name})",
      );
    }

    for (int i = 0; i < awayGoals; i++) {
      Player scorer = awayAttackers[rand.nextInt(awayAttackers.length)];
      goalScorers.update(scorer, (v) => v + 1, ifAbsent: () => 1);

      Player assist = awayAttackers[rand.nextInt(awayAttackers.length)];
      assists.update(assist, (v) => v + 1, ifAbsent: () => 1);

      events.add(
        "Goal for ${away.name}: ${scorer.name} (assisted by ${assist.name})",
      );
    }
  }

  /// Helper: simulate goals based on attacking/defending strength
  int _simulateGoals(double attackTeam, double defendTeam, Random rand) {
    double ratingDiff = attackTeam - defendTeam;
    double base = 1.5 + ratingDiff / 50;
    int goals = rand.nextInt((base + 1).ceil());
    return goals;
  }

  /// Returns next unplayed match for a given team
  bool isNextMatch(Team team) {
    return !played && (home == team || away == team);
  }

  /// Returns a readable string
  @override
  String toString() {
    if (played) return "${home.name} $homeGoals - $awayGoals ${away.name}";
    return "${home.name} vs ${away.name} (Week $week, Day $day)";
  }

  /// Reset match (for testing or replay)
  void reset() {
    played = false;
    homeGoals = null;
    awayGoals = null;
    events.clear();
    goalScorers.clear();
    assists.clear();
  }
}
