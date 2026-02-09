import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/league_provider.dart';
import '../../core/models/fixture.dart';

class FixturesTab extends StatelessWidget {
  const FixturesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final league = context.watch<LeagueProvider>();

    if (!league.initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Group fixtures by week & sort by day
    final Map<int, List<Fixture>> fixturesByWeek = {};
    for (final f in league.fixtures) {
      fixturesByWeek.putIfAbsent(f.week, () => []).add(f);
    }
    fixturesByWeek.forEach(
      (week, list) => list.sort((a, b) => a.day.compareTo(b.day)),
    );

    final sortedWeeks = fixturesByWeek.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sortedWeeks.length,
      itemBuilder: (context, index) {
        final week = sortedWeeks[index];
        final fixtures = fixturesByWeek[week]!;
        return _WeekSection(week: week, fixtures: fixtures, league: league);
      },
    );
  }
}

/* ===================================================== */

class _WeekSection extends StatelessWidget {
  final int week;
  final List<Fixture> fixtures;
  final LeagueProvider league;

  const _WeekSection({
    required this.week,
    required this.fixtures,
    required this.league,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "MATCHWEEK $week",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
        ...fixtures.map((f) => _FixtureTile(fixture: f, league: league)),
        const SizedBox(height: 12),
      ],
    );
  }
}

/* ===================================================== */

class _FixtureTile extends StatelessWidget {
  final Fixture fixture;
  final LeagueProvider league;

  const _FixtureTile({required this.fixture, required this.league});

  bool get isCurrentMatch =>
      !fixture.played &&
      fixture.week == league.currentWeek &&
      fixture.day == league.currentDay;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isCurrentMatch ? Colors.blueGrey.shade900 : Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _teamName(fixture.home.name),
            _scoreText(),
            _teamName(fixture.away.name),
          ],
        ),
        subtitle: Text(
          "Day ${fixture.day}",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ),
    );
  }

  Widget _teamName(String name) {
    return Expanded(
      child: Text(
        name,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _scoreText() {
    if (!fixture.played) {
      return const Text(
        "vs",
        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
      );
    }

    return Text(
      "${fixture.homeGoals} - ${fixture.awayGoals}",
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}
