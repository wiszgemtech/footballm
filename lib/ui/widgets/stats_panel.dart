import 'package:flutter/material.dart';
import '../../core/models/team.dart';

class StatsPanel extends StatelessWidget {
  final Team home;
  final Team away;

  const StatsPanel({super.key, required this.home, required this.away});

  @override
  Widget build(BuildContext context) {
    final homeTopScorer =
        home.players.isNotEmpty
            ? home.players.reduce((a, b) => a.goals > b.goals ? a : b)
            : null;
    final awayTopScorer =
        away.players.isNotEmpty
            ? away.players.reduce((a, b) => a.goals > b.goals ? a : b)
            : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Match Stats",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (homeTopScorer != null)
            Text(
              "${home.name} Top Scorer: ${homeTopScorer.name} (${homeTopScorer.goals})",
              style: const TextStyle(color: Colors.white),
            ),
          if (awayTopScorer != null)
            Text(
              "${away.name} Top Scorer: ${awayTopScorer.name} (${awayTopScorer.goals})",
              style: const TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
