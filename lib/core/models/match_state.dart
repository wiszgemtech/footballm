import 'package:footballmanager/core/models/player.dart';
import 'package:footballmanager/core/models/team.dart';

/// Stores per-player match stats
class PlayerMatchStats {
  final Player player;

  // Offensive
  int goals = 0;
  int assists = 0;
  int shots = 0;
  int shotsOnTarget = 0;
  int passesAttempted = 0;
  int passesCompleted = 0;
  int dribblesAttempted = 0;
  int dribblesCompleted = 0;

  // Defensive
  int tackles = 0;
  int interceptions = 0;
  int fouls = 0;
  int yellowCards = 0;
  int redCards = 0;

  // Goalkeeper
  int saves = 0;
  int goalsConceded = 0;

  // General
  int minutesPlayed = 0;
  double rating = 0.0; // Final match rating
  int motmPoints = 0; // For Man of the Match calculation

  PlayerMatchStats(this.player);
}

/// Stores per-team match stats
class TeamMatchStats {
  final Team team;

  // Team totals
  int goals = 0;
  int shots = 0;
  int shotsOnTarget = 0;
  int possessionSeconds = 0; // for possession %
  int corners = 0;
  int fouls = 0;
  int yellowCards = 0;
  int redCards = 0;
  int passesAttempted = 0;
  int passesCompleted = 0;
  int dribblesAttempted = 0;
  int dribblesCompleted = 0;

  TeamMatchStats(this.team);

  double get passAccuracy =>
      passesAttempted > 0 ? passesCompleted / passesAttempted * 100 : 0;

  double get dribbleSuccessRate =>
      dribblesAttempted > 0 ? dribblesCompleted / dribblesAttempted * 100 : 0;

  double get possessionPercentage(int totalSeconds) =>
      totalSeconds > 0 ? possessionSeconds / totalSeconds * 100 : 0;
}

/// Stores a single match event
class MatchEvent {
  final int minute;
  final String type; // "goal", "assist", "yellow", "red", "shot", "sub", "corner"
  final Player? player;
  final Player? assistPlayer;
  final Team team;
  final String description;

  MatchEvent({
    required this.minute,
    required this.type,
    required this.team,
    this.player,
    this.assistPlayer,
    required this.description,
  });
}

/// Full match state
class MatchState {
  final Team home;
  final Team away;

  // --------------------------------
  // Core match info
  // --------------------------------
  int minute = 0;
  bool isFirstHalf = true;
  bool halfTimeReached = false;
  bool fullTime = false;
  int addedTime = 0;

  // --------------------------------
  // Score
  // --------------------------------
  int homeGoals = 0;
  int awayGoals = 0;

  // --------------------------------
  // Possession tracking
  // --------------------------------
  Team possession; // Current possession
  Team lastPossession;

  // --------------------------------
  // Player stats
  // --------------------------------
  Map<Player, PlayerMatchStats> playerStats = {};

  // --------------------------------
  // Team stats
  // --------------------------------
  late TeamMatchStats homeStats;
  late TeamMatchStats awayStats;

  // --------------------------------
  // Events
  // --------------------------------
  List<MatchEvent> events = [];

  MatchState({
    required this.home,
    required this.away,
  })  : possession = home,
        lastPossession = home {
    // Initialize player stats
    for (var p in home.roster + away.roster) {
      playerStats[p] = PlayerMatchStats(p);
    }

    homeStats = TeamMatchStats(home);
    awayStats = TeamMatchStats(away);
  }

  /// Switch possession
  void switchPossession() {
    lastPossession = possession;
    possession = possession == home ? away : home;
  }

  /// Register a goal
  void registerGoal(Team scoringTeam, {required Player scorer, Player? assist}) {
    final stats = playerStats[scorer]!;
    stats.goals++;
    stats.motmPoints += 8; // arbitrary weighting

    if (assist != null) {
      final assistStats = playerStats[assist]!;
      assistStats.assists++;
      assistStats.motmPoints += 5;
    }

    if (scoringTeam == home) {
      homeGoals++;
      homeStats.goals++;
    } else {
      awayGoals++;
      awayStats.goals++;
    }

    events.add(MatchEvent(
      minute: minute,
      type: "goal",
      team: scoringTeam,
      player: scorer,
      assistPlayer: assist,
      description:
          "${scorer.name} scores for ${scoringTeam.name}" +
              (assist != null ? " assisted by ${assist.name}" : ""),
    ));
  }

  /// Register a shot
  void registerShot(Team team, {bool onTarget = false}) {
    final stats = team == home ? homeStats : awayStats;
    stats.shots++;
    if (onTarget) stats.shotsOnTarget++;
  }

  /// Register a corner
  void registerCorner(Team team) {
    final stats = team == home ? homeStats : awayStats;
    stats.corners++;
  }

  /// Register a card
  void registerCard(Player player, String type) {
    final stats = playerStats[player]!;
    if (type == "yellow") {
      stats.yellowCards++;
      player.yellowCards++;
      if (playerStats[player]!.yellowCards == 2) {
        registerCard(player, "red"); // automatic second yellow
      }
    } else if (type == "red") {
      stats.redCards++;
      player.redCards++;
      player.suspended = true;
    }

    final teamStats = home.roster.contains(player) ? homeStats : awayStats;
    if (type == "yellow") teamStats.yellowCards++;
    if (type == "red") teamStats.redCards++;

    events.add(MatchEvent(
      minute: minute,
      type: type,
      team: teamStats.team,
      player: player,
      description: "${player.name} receives a $type card",
    ));
  }

  /// Get match score text
  String scoreText() => "$homeGoals - $awayGoals";

  /// At the end of match, calculate player ratings
  void calculatePlayerRatings() {
    for (var stats in playerStats.values) {
      double rating = 50.0;

      // Offensive contribution
      rating += (stats.goals * 10);
      rating += (stats.assists * 7);
      rating += (stats.shotsOnTarget * 2);
      rating += (stats.passesCompleted / 10);
      rating += (stats.dribblesCompleted * 2);

      // Defensive contribution
      rating += (stats.tackles * 2);
      rating += (stats.interceptions * 2);
      rating -= (stats.fouls * 1);

      // Cards penalty
      rating -= (stats.yellowCards * 3);
      rating -= (stats.redCards * 7);

      stats.rating = rating.clamp(0, 100);
    }
  }

  /// Get Man of the Match
  Player? manOfTheMatch() {
    Player? best;
    double bestPoints = -1;
    for (var stats in playerStats.values) {
      if (stats.motmPoints > bestPoints) {
        bestPoints = stats.motmPoints.toDouble();
        best = stats.player;
      }
    }
    return best;
  }
}
