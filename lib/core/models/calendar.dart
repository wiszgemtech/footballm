/// calendar.dart
/// Handles in-game time, seasons, weeks, days, and events
library;
library;

import 'league.dart';
import 'season.dart';
import 'team.dart';
import 'player.dart';

enum SeasonPhase { preSeason, inSeason, postSeason }

class GameCalendar {
  int year;
  int month;
  int week;
  int day; // 1 = Monday, 7 = Sunday
  SeasonPhase phase;

  List<League> leagues = [];
  List<Season> seasons = [];

  GameCalendar({
    this.year = 2024,
    this.month = 8,
    this.week = 1,
    this.day = 1,
    this.phase = SeasonPhase.preSeason,
  });

  /// Advance one day
  void advanceDay() {
    day++;
    if (day > 7) {
      day = 1;
      advanceWeek();
    }
    _triggerDailyEvents();
  }

  /// Advance one week
  void advanceWeek() {
    week++;
    _triggerWeeklyEvents();
  }

  /// Advance one month
  void advanceMonth() {
    month++;
    if (month > 12) {
      month = 1;
      year++;
    }
    _triggerMonthlyEvents();
  }

  /// Start a new season
  void startNewSeason() {
    phase = SeasonPhase.preSeason;
    week = 1;
    day = 1;

    for (var league in leagues) {
      league.generateFixtures();
      league.resetTeamsStats();
    }

    _generateYouthPlayers();
    _applyPlayerAgingAndRetirements();
    _triggerPreSeasonEvents();
  }

  /// DAILY: matches + training
  void _triggerDailyEvents() {
    for (var league in leagues) {
      for (var fixture in league.fixtures) {
        if (!fixture.played && fixture.week == week && fixture.day == day) {
          fixture.play(); // Fixture handles everything
        }
      }

      _applyDailyTraining(league);
    }
  }

  /// WEEKLY: morale, form, finances
  void _triggerWeeklyEvents() {
    for (var league in leagues) {
      for (var team in league.teams) {
        team.applyWeeklyUpdates();
        team.applyWeeklyBudgetUpdate();
      }
    }
  }

  /// MONTHLY: injuries, staff
  void _triggerMonthlyEvents() {
    for (var league in leagues) {
      for (var team in league.teams) {
        _recoverInjuries(team);
        _evaluateStaff(team);
      }
    }
  }

  /// PRE-SEASON
  void _triggerPreSeasonEvents() {
    // Friendlies, scouting reset, media hype (later)
  }

  /// Youth intake
  void _generateYouthPlayers() {
    for (var league in leagues) {
      for (var team in league.teams) {
        team.generateYouthPlayers();
      }
    }
  }

  /// Aging & retirement
  void _applyPlayerAgingAndRetirements() {
    for (var league in leagues) {
      for (var team in league.teams) {
        final retired = <Player>[];

        for (var player in team.roster) {
          player.ageOneYear();
          if (player.age >= player.retirementAge) {
            retired.add(player);
          }
        }

        team.roster.removeWhere((p) => retired.contains(p));
      }
    }
  }

  /// Daily training
  void _applyDailyTraining(League league) {
    for (var team in league.teams) {
      team.trainPlayers();
    }
  }

  /// Injury recovery
  void _recoverInjuries(Team team) {
    for (var player in team.roster) {
      player.recoverInjury();
    }
  }

  /// Staff evaluation (placeholder)
  void _evaluateStaff(Team team) {
    team.morale = (team.morale + 0.5).clamp(0, 100);
  }

  String get formattedDate => "Year $year, Month $month, Week $week, Day $day";
}
