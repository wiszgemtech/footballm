import 'package:flutter/material.dart';
import '../../core/models/match_state.dart';

class ScoreboardWidget extends StatelessWidget {
  final MatchState match;

  const ScoreboardWidget({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final leadingColor =
        match.homeGoals > match.awayGoals
            ? Colors.greenAccent
            : match.awayGoals > match.homeGoals
            ? Colors.redAccent
            : Colors.white70;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          match.home.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "${match.homeGoals} - ${match.awayGoals}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: leadingColor,
          ),
        ),
        Text(
          match.away.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
