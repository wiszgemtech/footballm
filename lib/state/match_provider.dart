import 'package:flutter/material.dart';
import '../core/models/fixture.dart';
import '../core/models/team.dart';
import '../services/storage_helper.dart';
import '../data/league/premier_league_fixtures.dart';

class MatchProvider extends ChangeNotifier {
  List<Fixture> _fixtures = [];
  int _currentWeek = 1;

  List<Fixture> get fixtures => _fixtures;
  int get currentWeek => _currentWeek;

  /// Load fixtures from storage or use initial set
  Future<void> loadFixtures(List<Team> teams) async {
    final saved = await StorageService.loadFixtures(teams);
    if (saved.isNotEmpty) {
      _fixtures = saved;
    } else {
      _fixtures = PremierLeagueFixtures.allFixtures;
      await StorageService.saveFixtures(_fixtures);
    }
    _updateCurrentWeek();
    notifyListeners();
  }

  /// Play a fixture
  Future<void> playFixture(Fixture fixture) async {
    if (fixture.played) return;

    fixture.play();
    await StorageService.saveFixtures(_fixtures);

    _updateCurrentWeek();
    notifyListeners();
  }

  /// Next unplayed fixture for a specific team
  Fixture? nextFixtureForTeam(Team team) {
    try {
      return _fixtures.firstWhere(
        (f) =>
            !f.played &&
            f.week == _currentWeek &&
            (f.home.name == team.name || f.away.name == team.name),
      );
    } catch (e) {
      return null;
    }
  }

  /// Fixtures grouped by week (UI)
  Map<int, List<Fixture>> get fixturesByWeek {
    final map = <int, List<Fixture>>{};
    for (final f in _fixtures) {
      map.putIfAbsent(f.week, () => []).add(f);
    }
    return map;
  }

  void _updateCurrentWeek() {
    final unplayed = _fixtures.where((f) => !f.played);
    if (unplayed.isNotEmpty) {
      _currentWeek = unplayed.first.week;
    }
  }
}
