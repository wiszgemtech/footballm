import 'package:flutter/material.dart';
import '../../core/models/team.dart';
import '../../core/models/player.dart';

class SquadTab extends StatelessWidget {
  final Team selectedTeam;

  const SquadTab({super.key, required this.selectedTeam});

  @override
  Widget build(BuildContext context) {
    final players = selectedTeam.players;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, index) {
          Player p = players[index];
          return Card(
            color: Colors.grey[850],
            child: ListTile(
              title: Text(p.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                "${p.position} | Rating: ${p.rating} | Goals: ${p.goals} | Assists: ${p.assists}",
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}
