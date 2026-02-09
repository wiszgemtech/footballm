import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/team.dart';
import '../../core/models/fixture.dart';
import '../../state/team_provider.dart';
import '../../state/match_provider.dart';
import '../../state/league_provider.dart';
import 'squad_tab.dart';
import 'fixtures_tab.dart';
import 'stats_tab.dart';
import 'match_screen.dart';

class HomeScreen extends StatefulWidget {
  final Team selectedTeam;

  const HomeScreen({super.key, required this.selectedTeam});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final leagueProvider = context.watch<LeagueProvider>();
    final matchProvider = context.watch<MatchProvider>();
    final teamProvider = context.watch<TeamProvider>();

    // Next unplayed match for the selected team
    final nextMatch = matchProvider.nextFixtureForTeam(widget.selectedTeam);

    // Check if the team has any unplayed match this week
    final currentWeekFixtures =
        matchProvider.fixturesByWeek[matchProvider.currentWeek] ?? [];
    final hasMatchThisWeek = currentWeekFixtures.any(
      (f) =>
          !f.played &&
          (f.home.name == widget.selectedTeam.name ||
              f.away.name == widget.selectedTeam.name),
    );
    final isSimWeek = !hasMatchThisWeek && currentWeekFixtures.isNotEmpty;

    final tabs = [
      _homeTab(nextMatch, leagueProvider, matchProvider, isSimWeek),
      SquadTab(selectedTeam: widget.selectedTeam),
      const FixturesTab(),
      StatsTab(selectedTeam: widget.selectedTeam),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedTeam.name),
        backgroundColor: Colors.black87,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black87,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "My Squad"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Fixtures",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
        ],
      ),
    );
  }

  Widget _homeTab(
    Fixture? nextMatch,
    LeagueProvider leagueProvider,
    MatchProvider matchProvider,
    bool isSimWeek,
  ) {
    final table = leagueProvider.leagueTable;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Next Match"),
          if (nextMatch != null)
            Card(
              color: Colors.grey[850],
              child: ListTile(
                title: Text(
                  "${nextMatch.home.name} vs ${nextMatch.away.name}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                subtitle: Text(
                  nextMatch.played
                      ? "${nextMatch.homeGoals} - ${nextMatch.awayGoals}"
                      : "Week ${nextMatch.week}, Day ${nextMatch.day}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    if (isSimWeek) {
                      // Sim all remaining unplayed fixtures for the week
                      final weekFixtures =
                          matchProvider.fixturesByWeek[matchProvider
                              .currentWeek] ??
                          [];
                      for (final f in weekFixtures.where((f) => !f.played)) {
                        await matchProvider.playFixture(f);
                      }
                      await leagueProvider.initLeague();
                      await matchProvider.loadFixtures(leagueProvider.teams);
                      setState(() {});
                    } else if (!nextMatch.played) {
                      // Navigate to live match screen
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => MatchScreen(
                                home: nextMatch.home,
                                away: nextMatch.away,
                              ),
                        ),
                      );

                      // Refresh league table & fixtures after match
                      await leagueProvider.initLeague();
                      await matchProvider.loadFixtures(leagueProvider.teams);
                      setState(() {});
                    }
                  },
                  child: Text(isSimWeek ? "Sim Week" : "Play"),
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
              itemCount: table.length,
              itemBuilder: (context, index) {
                final entry = table[index];
                return Card(
                  color:
                      entry == widget.selectedTeam
                          ? Colors.blueGrey[900]
                          : Colors.grey[900],
                  child: ListTile(
                    title: Text(
                      "${index + 1}. ${entry.name}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      "${entry.points} pts | GF: ${entry.goalsFor} GA: ${entry.goalsAgainst} GD: ${entry.goalsFor - entry.goalsAgainst}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
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
}
