import 'dart:math';
import '../models/player.dart';
import '../models/team.dart';
import '../models/match_state.dart';
import 'possession_engine.dart';
import 'shot_engine.dart';
import 'commentary_engine.dart';

class MatchEngine {
  static final Random _rng = Random();

  /// Engine tick (~0.3s from UI)
  static void tick(MatchState match, void Function(String) liveCommentary) {
    if (match.fullTime) return;

    // -----------------------------
    // TIME FLOW
    // -----------------------------
    final pause = _advanceTime(match, liveCommentary);
    if (pause) return;

    // -----------------------------
    // STAMINA DRAIN (REALISTIC)
    // -----------------------------
    for (var p in match.home.players + match.away.players) {
      p.stamina = (p.stamina - 0.012).clamp(40.0, 100.0);
    }

    final Team attacking = match.possession;
    final Team defending = attacking == match.home ? match.away : match.home;

    // -----------------------------
    // TEAM DOMINANCE (90% SKILL)
    // -----------------------------
    final dominance = _teamDominance(attacking, defending);

    // -----------------------------
    // DECIDE IF ACTION OCCURS
    // -----------------------------
    if (dominance < 45) {
      _recyclePossession(attacking);
      return;
    }

    final Player ballCarrier = PossessionEngine.runPossessionChain(
      attacking,
      defending,
      match,
    );

    final String? commentary = _resolveFinalThird(
      player: ballCarrier,
      attacking: attacking,
      defending: defending,
      match: match,
    );

    if (commentary != null) {
      liveCommentary("⏱ ${match.minute}' $commentary");
    }

    _maybeSwitchPossession(match, dominance);
  }

  // ============================================================
  // FINAL THIRD LOGIC
  // ============================================================

  static String? _resolveFinalThird({
    required Player player,
    required Team attacking,
    required Team defending,
    required MatchState match,
  }) {
    final double shootChance = _shootProbability(player);
    final double roll = _rng.nextDouble() * 100;

    if (roll < shootChance) {
      match.registerShot(attacking, onTarget: false);

      final result = ShotEngine.takeShot(
        shooter: player,
        goalkeeper: defending.goalkeeper,
        difficultyMultiplier: _shotDifficulty(player, defending),
      );

      if (result.goal) {
        match.registerShot(attacking, onTarget: true);
        match.registerGoal(
          attacking,
          scorer: player,
          assist: player.lastPassRecipient,
        );

        return CommentaryEngine.goalCommentary(
          player: player,
          team: attacking,
          score: match.scoreText(),
        );
      }

      if (result.saved) {
        match.registerShot(attacking, onTarget: true);

        if (_rng.nextDouble() < 0.35) {
          match.registerCorner(attacking);
          return "${defending.goalkeeper.name} saves! Corner for ${attacking.name}";
        }

        return CommentaryEngine.missCommentary(player: player);
      }
    }

    return CommentaryEngine.passCommentary(player: player, team: attacking);
  }

  // ============================================================
  // TEAM DOMINANCE (CORE REALISM)
  // ============================================================

  static double _teamDominance(Team a, Team d) {
    final attackPower =
        (_avgSkill(a) * 0.35) +
        (_avgPace(a) * 0.25) +
        (_avgIntelligence(a) * 0.25) +
        (_avgStamina(a) * 0.15);

    final defenders = d.players.where(
      (p) =>
          p.position == "CB" ||
          p.position == "LB" ||
          p.position == "RB" ||
          p.position == "CDM",
    );

    double defenseSkill = 0;
    for (var p in defenders) {
      defenseSkill += (p.defending * 0.5) + (p.intelligence * 0.3) + (p.stamina * 0.2);
    }
    if (defenders.isNotEmpty) defenseSkill /= defenders.length;

    final defensePower =
        (defenseSkill * 0.55) + (_avgIntelligence(d) * 0.25) + (_avgStamina(d) * 0.20);

    final raw = attackPower - defensePower;

    return (raw + (_rng.nextDouble() * 10)).clamp(0, 100);
  }

  // ============================================================
  // SHOOTING REALISM
  // ============================================================

  static double _shootProbability(Player p) {
    double base;
    switch (p.position) {
      case "ST":
      case "CF":
        base = 60;
        break;
      case "LW":
      case "RW":
      case "CAM":
        base = 45;
        break;
      case "CM":
        base = 25;
        break;
      case "LB":
      case "RB":
        base = 15;
        break;
      default:
        base = 8;
    }

    base += (p.shooting - 50) * 0.3;
    base += (p.stamina - 50) * 0.2;

    return base.clamp(5, 75);
  }

  static double _shotDifficulty(Player shooter, Team defending) {
    final defenders = defending.players.where(
      (p) =>
          p.position == "CB" ||
          p.position == "LB" ||
          p.position == "RB" ||
          p.position == "CDM",
    );

    double defenseStrength = 0;
    for (var d in defenders) {
      defenseStrength += (d.defending * 0.5) + (d.intelligence * 0.3) + (d.stamina * 0.2);
    }
    if (defenders.isNotEmpty) defenseStrength /= defenders.length;

    final diff = ((defenseStrength - shooter.shooting) / 120).clamp(-0.25, 0.4);
    return 1 + diff;
  }

  // ============================================================
  // POSSESSION FLOW
  // ============================================================

  static void _recyclePossession(Team team) {
    for (var p in team.players) {
      p.rating += 0.002;
    }
  }

  static void _maybeSwitchPossession(MatchState match, double dominance) {
    final switchChance = dominance < 50 ? 0.35 : 0.15;
    if (_rng.nextDouble() < switchChance) match.switchPossession();
  }

  // ============================================================
  // TIME MANAGEMENT
  // ============================================================

  static bool _advanceTime(MatchState match, void Function(String) liveCommentary) {
    match.minute++;

    if (match.minute == 45 && !match.halfTimeReached) {
      match.halfTimeReached = true;
      match.isFirstHalf = false;
      liveCommentary("⏸ HALF TIME: ${match.scoreText()}");
      return true;
    }

    if (match.minute == 46 && match.halfTimeReached) {
      liveCommentary("▶ SECOND HALF UNDERWAY");
    }

    if (match.minute == 90) match.addedTime = 3 + _rng.nextInt(4);

    if (match.minute >= 90 + match.addedTime) {
      match.fullTime = true;
      liveCommentary(
        "🔚 FULL TIME: ${match.home.name} ${match.homeGoals} - ${match.awayGoals} ${match.away.name}",
      );
      return true;
    }

    return false;
  }

  // ============================================================
  // TEAM ATTRIBUTE HELPERS
  // ============================================================

  static double _avgStamina(Team team) {
    if (team.players.isEmpty) return 50;
    return team.players.map((p) => p.stamina).reduce((a, b) => a + b) / team.players.length;
  }

  static double _avgIntelligence(Team team) {
    if (team.players.isEmpty) return 50;
    return team.players.map((p) => p.intelligence).reduce((a, b) => a + b) / team.players.length;
  }

  static double _avgSkill(Team team) {
    if (team.players.isEmpty) return 50;
    return team.players
            .map((p) =>
                p.pace +
                p.shooting +
                p.passing +
                p.dribbling +
                p.defending +
                p.physical +
                p.technique +
                p.vision)
            .reduce((a, b) => a + b) /
        (team.players.length * 8);
  }

  static double _avgPace(Team team) {
    if (team.players.isEmpty) return 50;
    return team.players.map((p) => p.pace).reduce((a, b) => a + b) / team.players.length;
  }
}

// ============================================================
// TEAM & PLAYER EXTENSIONS
// ============================================================

extension TeamMatchExtensions on Team {
  List<Player> get players => seniorSquad;

  Player get goalkeeper =>
      seniorSquad.firstWhere(
        (p) => p.position == 'GK',
        orElse: () => Player(
          id: 'dummyGK',
          name: 'Dummy GK',
          age: 30,
          nationality: country,
          countryOfBirth: country,
          position: 'GK',
          squadNumber: 1,
          preferredFoot: 'Right',
        ),
      );
}

extension PlayerMatchExtensions on Player {
  Player? lastPassRecipient;
  double rating = 75;
}

// ============================================================
// STUB: PossessionEngine.runPossessionChain
// ============================================================

extension PossessionEngineStub on PossessionEngine {
  static Player runPossessionChain(Team attacking, Team defending, MatchState match) {
    // Replace with your real possession logic
    return attacking.players.first;
  }
}
