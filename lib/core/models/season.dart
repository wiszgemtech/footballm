// TODO Implement this library.
/// season.dart
/// Handles a full season for a league: matches, weeks, updates, awards.

import 'league.dart';
import 'team.dart';
import 'fixture.dart';
import 'player.dart';
import 'calendar.dart';

class Season {
  League league;
  GameCalendar calendar;

  // Tracks current week of the season
  int currentWeek;

  Season({required this.league, required this.calendar, this.currentWeek = 1});

  /// Generates all fixtures for the league season
  void generateFixtures() {
    league.generateFixtures();
  }

  /// Play all matches for the current week
  void playWeek() {
    final weekFixtures = league.fixtures.where(
      (f) => f.week == currentWeek && !f.played,
    );

    for (final fixture in weekFixtures) {
      fixture.play(); // simulate match using team ratings
    }

    // Apply weekly updates: player stats, morale, fatigue
    applyEndOfWeekUpdates();

    // Advance calendar to next week
    calendar.advanceWeek();
    currentWeek = calendar.week;

    // Update league standings after week
    league.updateStandings();
  }

  /// Apply updates at the end of each week
  void applyEndOfWeekUpdates() {
    for (final team in league.teams) {
      for (final player in team.roster) {
        //  player.applyWeeklyTraining(); // training progression
        player.applyFormMorale(); // morale & form adjustments
        //  player.reduceFatigue(); // stamina/fatigue system
      }
      team.applyWeeklyBudgetUpdate(); // finances & revenue
    }
  }

  /// Apply end-of-season events: promotions, relegations, awards
  void applyEndOfSeasonEvents(List<League> allLeagues) {
    // Promotions/Relegations
    league.checkPromotionsRelegations(allLeagues);

    // Awards
    _applyAwards();

    // Age players and handle retirements
    _agePlayers();
  }

  void _applyAwards() {
    // Top scorer
    final allPlayers = league.teams.expand((t) => t.roster).toList();
    allPlayers.sort((a, b) => b.goals - a.goals);
    Player topScorer = allPlayers.first;

    // Example award
    topScorer.awards.add("Top Scorer");

    // Add more awards: Manager of the Year, Best Young Player, etc.
  }

  void _agePlayers() {
    for (final team in league.teams) {
      for (final player in team.roster) {
        player.ageOneYear();
        if (player.age >= player.retirementAge) {
          // Retire player
          team.roster.remove(player);
        }
      }
    }
  }
}
