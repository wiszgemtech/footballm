import '../models/player.dart';
import '../models/team.dart';
import 'dart:math';

class CommentaryEngine {
  static final Random _rng = Random();

  static final List<String> goalTemplates = [
    "What a strike by {player}! The crowd goes wild!",
    "{player} finds the back of the net for {team}!",
    "A clinical finish by {player}! Score now {score}",
    "{player} makes it count! {team} leads!",
  ];

  static final List<String> missTemplates = [
    "{player} misses the chance! Oh so close!",
    "What a save! {player}'s shot denied!",
    "{player} fires just wide!",
    "A poor finish by {player}, unlucky!",
  ];

  static final List<String> passTemplates = [
    "{player} passes skillfully to a teammate.",
    "A quick one-two by {player} and {team} advances.",
    "{player} finds space and delivers a precise ball.",
  ];

  static String goalCommentary({
    required Player player,
    required Team team,
    required String score,
  }) {
    String template = goalTemplates[_rng.nextInt(goalTemplates.length)];
    return template
        .replaceAll("{player}", player.name)
        .replaceAll("{team}", team.name)
        .replaceAll("{score}", score);
  }

  static String missCommentary({required Player player}) {
    String template = missTemplates[_rng.nextInt(missTemplates.length)];
    return template.replaceAll("{player}", player.name);
  }

  static String passCommentary({required Player player, required Team team}) {
    String template = passTemplates[_rng.nextInt(passTemplates.length)];
    return template
        .replaceAll("{player}", player.name)
        .replaceAll("{team}", team.name);
  }
}
