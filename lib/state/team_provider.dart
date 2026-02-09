import 'package:flutter/material.dart';
import '../core/models/team.dart';
import '../services/storage_helper.dart';

class TeamProvider extends ChangeNotifier {
  List<Team> _teams = [];

  List<Team> get teams => _teams;

  /// Load teams from storage or initialize
  Future<void> loadTeams(List<Team> initialTeams) async {
    final saved = await StorageService.loadTeams();
    if (saved.isNotEmpty) {
      _teams = saved;
    } else {
      _teams = initialTeams;
      await StorageService.saveTeams(_teams);
    }
    notifyListeners();
  }

  /// Update team stats after match
  void updateTeam(Team team) {
    final index = _teams.indexWhere((t) => t.name == team.name);
    if (index != -1) {
      _teams[index] = team;
      StorageService.saveTeams(_teams);
      notifyListeners();
    }
  }

  /// Sorted league table (FM style)
  List<Team> get leagueTable {
    final sorted = List<Team>.from(_teams);
    sorted.sort((a, b) {
      if (b.points != a.points) return b.points.compareTo(a.points);
      final gdA = a.goalsFor - a.goalsAgainst;
      final gdB = b.goalsFor - b.goalsAgainst;
      if (gdB != gdA) return gdB.compareTo(gdA);
      return b.goalsFor.compareTo(a.goalsFor);
    });
    return sorted;
  }
}
