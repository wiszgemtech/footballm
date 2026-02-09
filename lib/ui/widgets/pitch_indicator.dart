import 'package:flutter/material.dart';
import '../../core/models/team.dart';
import '../../core/models/player.dart';

class PitchIndicator extends StatelessWidget {
  final Team home;
  final Team away;
  final Team possession;

  const PitchIndicator({
    super.key,
    required this.home,
    required this.away,
    required this.possession,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[800],
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Midline
            Positioned(
              top: double.infinity / 2,
              left: 0,
              right: 0,
              child: Container(height: 2, color: Colors.white),
            ),
            // Players
            ..._buildPlayers(home.players, isHome: true),
            ..._buildPlayers(away.players, isHome: false),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPlayers(List<Player> players, {required bool isHome}) {
    final rows = <double>[0.1, 0.35, 0.6, 0.85];
    final List<Widget> widgets = [];

    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      final yPos = rows[i % rows.length];
      final xPos = isHome ? 0.1 + (i % 4) * 0.15 : 0.85 - (i % 4) * 0.15;
      widgets.add(
        Positioned(
          top: yPos * 300,
          left: xPos * 200,
          child: _playerDot(player, possession == (isHome ? home : away)),
        ),
      );
    }
    return widgets;
  }

  Widget _playerDot(Player player, bool hasBall) {
    return Column(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasBall ? Colors.yellow : Colors.white,
            border: Border.all(color: Colors.black, width: 1),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          player.number.toString(),
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ],
    );
  }
}
