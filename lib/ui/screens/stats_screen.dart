import 'package:flutter/material.dart';
import '../../core/models/team.dart';

class StatsScreen extends StatelessWidget {
  final Team team;

  const StatsScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${team.name} Stats")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Player Stats",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: team.players.length,
                itemBuilder: (context, index) {
                  final p = team.players[index];
                  return Card(
                    color: Colors.grey[850],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        p.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "Pos: ${p.position} | Goals: ${p.goals} | Assists: ${p.assists} | Shots: ${p.shots}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
