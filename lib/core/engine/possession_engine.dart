import 'dart:math';
import '../models/match_state.dart';
import '../models/player.dart';
import '../models/team.dart';
import 'shot_engine.dart';

class PossessionEngine {
  static final Random _rng = Random();

  /// Run a single possession sequence
  static void runPossession(MatchState match) {
    final Team attacking = match.possession;
    final Team defending = attacking == match.home ? match.away : match.home;

    final Player actor = _selectActor(attacking);
    final String action = _decideAction(actor, attacking, defending);

    switch (action) {
      case 'shot':
        _handleShot(actor, attacking, defending, match);
        break;
      case 'dribble':
        _handleDribble(actor, defending, match);
        break;
      case 'pass':
      default:
        _handlePass(actor, attacking, match);
        break;
    }

    if (_rng.nextDouble() < 0.12) match.switchPossession();
  }

  static Player _selectActor(Team team) {
    final players = team.seniorSquad.where((p) => p.position != 'GK').toList();
    players.sort((a, b) {
      double scoreA = a.calculateOverall() * 0.5 + a.form * 0.3 + a.morale * 0.2 + _rng.nextDouble() * 5;
      double scoreB = b.calculateOverall() * 0.5 + b.form * 0.3 + b.morale * 0.2 + _rng.nextDouble() * 5;
      return scoreB.compareTo(scoreA);
    });
    return players.first;
  }

  static String _decideAction(Player player, Team attacking, Team defending) {
    final double shotWeight = _shotBias(player.position, attacking.playingStyle);
    final double passWeight = player.passing * 0.7 + player.vision * 0.3;
    final double dribbleWeight = player.dribbling * 0.6 + player.pace * 0.4;

    final double total = shotWeight + passWeight + dribbleWeight;
    final double roll = _rng.nextDouble() * total;

    if (roll < shotWeight) return 'shot';
    if (roll < shotWeight + dribbleWeight) return 'dribble';
    return 'pass';
  }

  static double _shotBias(String position, String style) {
    double base;
    switch (position) {
      case 'ST':
      case 'CF':
        base = 55;
        break;
      case 'LW':
      case 'RW':
      case 'AM':
        base = 45;
        break;
      case 'CM':
        base = 25;
        break;
      case 'CB':
      case 'LB':
      case 'RB':
        base = 10;
        break;
      default:
        base = 5;
    }

    if (style == 'Attacking') base += 10;
    if (style == 'Counter') base += 5;
    if (style == 'Defensive') base -= 8;

    return base.clamp(0, 100);
  }

  static void _handlePass(Player player, Team attacking, MatchState match) {
    final stats = match.playerStats[player]!;

    double successChance = player.passing * 0.6 + player.vision * 0.2 + player.intelligence * 0.2;
    successChance *= attacking.teamChemistry / 100;
    successChance *= (player.form + player.morale) / 200;
    successChance *= (1 - player.fatigue / 120);
    successChance = successChance.clamp(5, 95);

    stats.passesAttempted++;
    if (_rng.nextDouble() * 100 < successChance) {
      stats.passesCompleted++;
    } else {
      match.switchPossession();
    }
  }

  static void _handleDribble(Player player, Team defending, MatchState match) {
    final stats = match.playerStats[player]!;
    double successChance = player.dribbling * 0.6 + player.pace * 0.4;
    double defensePressure = defending.calculateTeamStrength() / 100;
    successChance *= (1 - defensePressure * 0.25);
    successChance *= (player.form / 100);
    successChance *= (1 - player.fatigue / 120);
    successChance = successChance.clamp(5, 90);

    stats.dribblesAttempted++;
    if (_rng.nextDouble() * 100 < successChance) {
      stats.dribblesCompleted++;
    } else {
      match.switchPossession();
    }
  }

  static void _handleShot(Player shooter, Team attacking, Team defending, MatchState match) {
    final goalkeeper = defending.seniorSquad.firstWhere((p) => p.position == 'GK');
    final result = ShotEngine.takeShot(
      shooter: shooter,
      goalkeeper: goalkeeper,
      difficultyMultiplier: 1 + (defending.calculateTeamStrength() / 200),
      fatigueEffect: 1 - shooter.fatigue / 120,
      pressure: defending.teamChemistry / 100,
    );

    match.registerShot(attacking, onTarget: result.goal || result.saved);
    if (result.goal) match.registerGoal(attacking, scorer: shooter);
  }
}