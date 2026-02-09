import 'package:flutter/material.dart';
import 'package:footballmanager/ui/screens/match_screen.dart';
import '../../core/models/team.dart';
import '../../core/models/fixture.dart';
import '../../data/league/premier_league_fixtures.dart';
import '../../data/league/premier_league_schedule.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatefulWidget {
  final Team selectedTeam;
  final VoidCallback onUpdate;

  const HomeTab({
    super.key,
    required this.selectedTeam,
    required this.onUpdate,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Fixture? nextMatch;
  List<Team> leagueTable = [];

  @override
  void initState() {
    super.initState();
    _loadLeague();
    _findNextMatch();
  }

  Future<void> _loadLeague() async {
    final prefs = await SharedPreferences.getInstance();
    leagueTable = PremierLeagueSchedule.teams;

    // Load each team stats from prefs
    for (var team in leagueTable) {
      team.points = prefs.getInt('${team.name}_points') ?? 0;
      team.goalsFor = prefs.getInt('${team.name}_goalsFor') ?? 0;
      team.goalsAgainst = prefs.getInt('${team.name}_goalsAgainst') ?? 0;
      // Add more stats like wins/draws/losses if needed
    }

    _sortLeague();
    setState(() {});
  }

  void _sortLeague() {
    leagueTable.sort((a, b) {
      if (b.points != a.points) return b.points.compareTo(a.points);
      if (b.goalDifference != a.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      return b.goalsFor.compareTo(a.goalsFor);
    });
  }

  void _findNextMatch() {
    final fixture = PremierLeagueFixtures.allFixtures.firstWhere(
      (f) =>
          (f.home == widget.selectedTeam || f.away == widget.selectedTeam) &&
          (f.home.points + f.away.points == 0), // not played yet
      orElse:
          () => Fixture(
            home: widget.selectedTeam,
            away: widget.selectedTeam,
            week: 0,
            day: 1,
          ),
    );

    // Treat week 0 as "no upcoming match"
    nextMatch = fixture.week == 0 ? null : fixture;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Next Match"),
          if (nextMatch != null)
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => MatchScreen(
                          home: nextMatch!.home,
                          away: nextMatch!.away,
                        ),
                  ),
                );
                await _loadLeague(); // Refresh after match
                widget.onUpdate();
                _findNextMatch();
              },
              child: Card(
                color: Colors.grey[850],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${nextMatch!.home.name} vs ${nextMatch!.away.name}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const Icon(Icons.sports_soccer, color: Colors.white),
                    ],
                  ),
                ),
              ),
            )
          else
            const Text(
              "No upcoming match",
              style: TextStyle(color: Colors.white),
            ),

          const SizedBox(height: 20),
          _sectionTitle("League Table"),
          Expanded(
            child: ListView.builder(
              itemCount: leagueTable.length,
              itemBuilder: (context, index) {
                final team = leagueTable[index];
                return ListTile(
                  tileColor: Colors.grey[900],
                  title: Text(
                    team.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "GF: ${team.goalsFor} | GA: ${team.goalsAgainst} | GD: ${team.goalDifference}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    "${team.points} pts",
                    style: const TextStyle(color: Colors.white70),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
