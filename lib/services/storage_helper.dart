import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/team.dart';
import '../core/models/player.dart';
import '../core/models/fixture.dart';

class StorageService {
  static const _teamsKey = 'teams_data';
  static const _fixturesKey = 'fixtures_data';
  static const _metaKey = 'league_meta';

  /* ===================== TEAMS ===================== */

  static Future<void> saveTeams(List<Team> teams) async {
    final prefs = await SharedPreferences.getInstance();
    final data = teams.map((t) => jsonEncode(_teamToMap(t))).toList();
    await prefs.setStringList(_teamsKey, data);
  }

  static Future<List<Team>> loadTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_teamsKey) ?? [];
    return data.map((e) => _teamFromMap(jsonDecode(e))).toList();
  }

  /* ===================== FIXTURES ===================== */

  static Future<void> saveFixtures(List<Fixture> fixtures) async {
    final prefs = await SharedPreferences.getInstance();
    final data = fixtures.map((f) => jsonEncode(_fixtureToMap(f))).toList();
    await prefs.setStringList(_fixturesKey, data);
  }

  static Future<List<Fixture>> loadFixtures(List<Team> teams) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_fixturesKey) ?? [];
    return data.map((e) => _fixtureFromMap(jsonDecode(e), teams)).toList();
  }

  /* ===================== META (WEEK / DAY) ===================== */

  static Future<void> saveMeta(int week, int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_metaKey, jsonEncode({'week': week, 'day': day}));
  }

  static Future<Map<String, int>> loadMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_metaKey);
    if (raw == null) return {'week': 1, 'day': 1};
    final map = jsonDecode(raw);
    return {'week': map['week'], 'day': map['day']};
  }

  /* ===================== MAPPERS ===================== */

  static Map<String, dynamic> _teamToMap(Team t) => {
    'name': t.name,
    'points': t.points,
    'goalsFor': t.goalsFor,
    'goalsAgainst': t.goalsAgainst,
    'players': t.players.map(_playerToMap).toList(),
  };

  static Team _teamFromMap(Map<String, dynamic> map) {
    return Team(
      name: map['name'],
      points: map['points'],
      goalsFor: map['goalsFor'],
      goalsAgainst: map['goalsAgainst'],
      players: (map['players'] as List).map((p) => _playerFromMap(p)).toList(),
    );
  }

  static Map<String, dynamic> _playerToMap(Player p) => {
    'name': p.name,
    'position': p.position,
    'number': p.number,
    'rating': p.rating,
    'pace': p.pace,
    'intelligence': p.intelligence,
    'goals': p.goals,
    'assists': p.assists,
  };

  static Player _playerFromMap(Map<String, dynamic> map) => Player(
    name: map['name'],
    position: map['position'],
    number: map['number'],
    rating: map['rating'],
    pace: map['pace'],
    intelligence: map['intelligence'],
    goals: map['goals'],
    assists: map['assists'],
  );

  static Map<String, dynamic> _fixtureToMap(Fixture f) => {
    'home': f.home.name,
    'away': f.away.name,
    'week': f.week,
    'day': f.day,
    'homeGoals': f.homeGoals,
    'awayGoals': f.awayGoals,
    'played': f.played,
  };

  static Fixture _fixtureFromMap(Map<String, dynamic> map, List<Team> teams) {
    final home = teams.firstWhere((t) => t.name == map['home']);
    final away = teams.firstWhere((t) => t.name == map['away']);

    return Fixture(
      home: home,
      away: away,
      week: map['week'],
      day: map['day'],
      homeGoals: map['homeGoals'],
      awayGoals: map['awayGoals'],
      played: map['played'],
    );
  }
}
