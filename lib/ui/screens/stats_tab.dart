import 'package:flutter/material.dart';
import '../../core/models/team.dart';
import '../../core/models/player.dart';

class StatsTab extends StatelessWidget {
  final Team selectedTeam;

  const StatsTab({super.key, required this.selectedTeam});

  @override
  Widget build(BuildContext context) {
    final players = selectedTeam.players;

    // Top Scorer
    final topScorer = (players..sort((a, b) => b.goals.compareTo(a.goals)))
        .firstWhere((p) => p.goals > 0, orElse: () => players.first);

    // Top Assist
    final topAssist = (players..sort((a, b) => b.assists.compareTo(a.assists)))
        .firstWhere((p) => p.assists > 0, orElse: () => players.first);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Top Stats"),
          const SizedBox(height: 10),
          Text(
            "Top Scorer: ${topScorer.name} (${topScorer.goals})",
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            "Top Assist: ${topAssist.name} (${topAssist.assists})",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          _sectionTitle("Player Ratings"),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                Player p = players[index];
                return Card(
                  color: Colors.grey[850],
                  child: ListTile(
                    title: Text(
                      p.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Rating: ${p.rating}",
                      style: const TextStyle(color: Colors.white70),
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
