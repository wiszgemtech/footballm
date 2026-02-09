/// league.dart
/// Represents a league, its teams, fixtures, standings, and season flow.

import 'team.dart';
import 'fixture.dart';
import 'season.dart';

class League {
  // Basic Info
  String name;
  String country;
  int tier; // 1 = top division, 2 = second division, etc.

  // Teams in the league
  List<Team> teams;

  // Fixtures and results
  List<Fixture> fixtures;

  // Season tracking
  int currentWeek = 1;
  int currentDay = 1;

  // League rules
  int pointsWin;
  int pointsDraw;
  int pointsLoss;
  int promotionSpots; // Number of teams promoted at season end
  int relegationSpots; // Number of teams relegated at season end

  League({
    required this.name,
    required this.country,
    required this.tier,
    required this.teams,
    this.fixtures = const [],
    this.currentWeek = 1,
    this.currentDay = 1,
    this.pointsWin = 3,
    this.pointsDraw = 1,
    this.pointsLoss = 0,
    this.promotionSpots = 3,
    this.relegationSpots = 3,
  });

  /// Generate all fixtures for the season
  void generateFixtures() {
    fixtures = [];
    int totalWeeks = (teams.length - 1) * 2; // double round-robin
    int halfSize = teams.length ~/ 2;

    List<Team> teamOrder = List.from(teams);

    // First half of the season
    for (int week = 1; week <= totalWeeks ~/ 2; week++) {
      for (int i = 0; i < halfSize; i++) {
        Team home = teamOrder[i];
        Team away = teamOrder[teamOrder.length - 1 - i];
        int day = 1 + (i % 7); // staggered Mon-Sun
        fixtures.add(Fixture(home: home, away: away, week: week, day: day));
      }
      Team last = teamOrder.removeLast();
      teamOrder.insert(1, last);
    }

    // Second half of the season - reverse home/away
    List<Team> secondHalfOrder = List.from(teams);
    for (int week = totalWeeks ~/ 2 + 1; week <= totalWeeks; week++) {
      for (int i = 0; i < halfSize; i++) {
        Team home = secondHalfOrder[secondHalfOrder.length - 1 - i];
        Team away = secondHalfOrder[i];
        int day = 1 + (i % 7);
        fixtures.add(Fixture(home: home, away: away, week: week, day: day));
      }
      Team last = secondHalfOrder.removeLast();
      secondHalfOrder.insert(1, last);
    }
  }

  /// Update league standings based on played fixtures
  void updateStandings() {
    // Reset stats
    for (var team in teams) {
      team.matchesPlayed = 0;
      team.wins = 0;
      team.draws = 0;
      team.losses = 0;
      team.goalsFor = 0;
      team.goalsAgainst = 0;
      team.points = 0;
    }

    // Apply results
    for (var fixture in fixtures.where((f) => f.played)) {
      Team home = fixture.home;
      Team away = fixture.away;

      home.goalsFor += fixture.homeGoals!;
      home.goalsAgainst += fixture.awayGoals!;
      away.goalsFor += fixture.awayGoals!;
      away.goalsAgainst += fixture.homeGoals!;

      if (fixture.homeGoals! > fixture.awayGoals!) {
        home.wins++;
        home.points += pointsWin;
        away.losses++;
        away.points += pointsLoss;
      } else if (fixture.homeGoals! < fixture.awayGoals!) {
        away.wins++;
        away.points += pointsWin;
        home.losses++;
        home.points += pointsLoss;
      } else {
        // Draw
        home.draws++;
        away.draws++;
        home.points += pointsDraw;
        away.points += pointsDraw;
      }

      home.matchesPlayed++;
      away.matchesPlayed++;
    }
  }

  /// Returns league table sorted FM-style
  List<Team> leagueTable() {
    final table = List<Team>.from(teams);
    table.sort((a, b) {
      if (b.points != a.points) return b.points - a.points;
      final gdA = a.goalsFor - a.goalsAgainst;
      final gdB = b.goalsFor - b.goalsAgainst;
      if (gdB != gdA) return gdB - gdA;
      return b.goalsFor - a.goalsFor;
    });
    return table;
  }

  /// Check promotions and relegations at season end
  void checkPromotionsRelegations(List<League> allLeagues) {
    // Sort table
    final table = leagueTable();

    // Relegate bottom teams
    if (relegationSpots > 0 && tier > 1) {
      for (int i = 0; i < relegationSpots; i++) {
        Team relegated = table[table.length - 1 - i];
        // Move to lower league
        League lowerLeague = allLeagues.firstWhere(
          (l) => l.tier == tier + 1,
          orElse: () => this,
        );
        lowerLeague.teams.add(relegated);
        teams.remove(relegated);
      }
    }

    // Promote top teams
    if (promotionSpots > 0 && tier < allLeagues.length) {
      for (int i = 0; i < promotionSpots; i++) {
        Team promoted = table[i];
        League upperLeague = allLeagues.firstWhere(
          (l) => l.tier == tier - 1,
          orElse: () => this,
        );
        upperLeague.teams.add(promoted);
        teams.remove(promoted);
      }
    }
  }

  /// Advance to next day/week in the league calendar
  void advanceDay() {
    currentDay++;
    if (currentDay > 7) {
      currentDay = 1;
      currentWeek++;
    }
  }

  /// Get next fixture for a specific team
  Fixture? nextFixtureForTeam(Team team) {
    try {
      return fixtures.firstWhere(
        (f) => !f.played && (f.home == team || f.away == team),
      );
    } catch (_) {
      return null;
    }
  }

  /// Reset all teams' season stats (used before new season or fixture generation)
  void resetTeamsStats() {
    for (final team in teams) {
      team.matchesPlayed = 0;
      team.wins = 0;
      team.draws = 0;
      team.losses = 0;
      team.goalsFor = 0;
      team.goalsAgainst = 0;
      team.points = 0;

      // Optional: reset team-level form or momentum if you track it
      // team.teamForm = 0;
    }
  }
}
