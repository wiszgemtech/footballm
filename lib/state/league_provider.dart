import 'package:flutter/foundation.dart';
import '../core/models/fixture.dart';
import '../core/models/team.dart';
import '../services/storage_helper.dart';
import '../data/league/premier_league_schedule.dart';

class LeagueProvider extends ChangeNotifier {
  List<Team> teams = [];
  List<Fixture> fixtures = [];

  int currentWeek = 1;
  int currentDay = 1;
  bool initialized = false;

  /// Initialize league
  Future<void> initLeague() async {
    teams = await StorageService.loadTeams();
    // fixtures = [];

    if (teams.isEmpty) {
      teams = PremierLeagueSchedule.teams;
      fixtures = PremierLeagueSchedule.generateFixtures();
      await _saveAll();
    } else {
      fixtures = await StorageService.loadFixtures(teams);
      final meta = await StorageService.loadMeta();
      currentWeek = meta['week'] ?? 1;
      currentDay = meta['day'] ?? 1;
    }

    initialized = true;
    notifyListeners();
  }

  /// Next match to play (by week & day)
  Fixture? get nextFixture {
    try {
      return fixtures.firstWhere(
        (f) => !f.played && f.week == currentWeek && f.day == currentDay,
      );
    } catch (_) {
      return null;
    }
  }

  /// All fixtures for a given week
  List<Fixture> fixturesByWeek(int week) =>
      fixtures.where((f) => f.week == week).toList();

  /// Play the next match (auto updates teams & storage)
  void playNextMatch({int? homeGoals, int? awayGoals}) {
    final match = nextFixture;
    if (match == null) return;

    match.play(homeScore: homeGoals, awayScore: awayGoals);

    _advanceTime();
    _saveAll();
    notifyListeners();
  }

  void _advanceTime() {
    currentDay++;
    if (currentDay > 7) {
      currentDay = 1;
      currentWeek++;
    }
  }

  /// League table sorted FM style
  List<Team> get leagueTable {
    final table = [...teams];
    table.sort((a, b) {
      if (b.points != a.points) return b.points - a.points;
      final gdA = a.goalsFor - a.goalsAgainst;
      final gdB = b.goalsFor - b.goalsAgainst;
      if (gdB != gdA) return gdB - gdA;
      return b.goalsFor - a.goalsFor;
    });
    return table;
  }

  /// Save teams, fixtures, and meta
  Future<void> _saveAll() async {
    await StorageService.saveTeams(teams);
    await StorageService.saveFixtures(fixtures);
    await StorageService.saveMeta(currentWeek, currentDay);
  }
}
