import 'player.dart';
import 'youth_player.dart';

/// Represents a football/soccer team
class Team {
  // ===================== BASIC INFO =====================
  String id; // Unique identifier
  String name;
  String country;
  String league;
  String shortName;
  String emblemUrl;

  // ===================== FINANCES =====================
  double budget; // Total budget in millions
  double wageBudget; // Weekly wage budget
  double transferBudget; // Transfer budget
  double clubValue; // Overall club value

  // ===================== ROSTER =====================
  List<Player> seniorSquad;
  List<YouthPlayer> youthSquad;
  List<Player> get roster => seniorSquad;

  // ===================== FORMATION & TACTICS =====================
  String formation; // e.g., "4-3-3", "3-5-2"
  String playingStyle; // e.g., "Possession", "Counter", "High Press"
  double teamChemistry; // 0-100
  double morale; // Team morale 0-100

  // ===================== MATCH STATS =====================
  int matchesPlayed;
  int wins;
  int draws;
  int losses;
  int goalsFor;
  int goalsAgainst;
  int points;

  // ===================== STAFF =====================
  String manager;
  String assistantManager;
  String coach; // For training
  String scout;
  String physiotherapist;
  String goalkeeperCoach;

  /// Temporary staff list wrapper (until Staff becomes a proper class)
  List<String> get staff => [
    manager,
    assistantManager,
    coach,
    scout,
    physiotherapist,
    goalkeeperCoach,
  ];

  // ===================== YOUTH ACADEMY =====================
  int youthAcademyLevel; // 1-5, affects quality of youth players
  int homegrownPlayers; // Number of youth promoted
  double youthInvestment; // Money invested in youth per season

  // ===================== HISTORY & ACHIEVEMENTS =====================
  List<String> pastTrophies;
  List<String> pastLeagues;
  Map<String, int> records; // e.g., "HighestScorer": 25

  // ===================== CONSTRUCTOR =====================
  Team({
    required this.id,
    required this.name,
    this.country = '',
    this.league = '',
    this.shortName = '',
    this.emblemUrl = '',
    this.budget = 0,
    this.wageBudget = 0,
    this.transferBudget = 0,
    this.clubValue = 0,
    List<Player>? seniorSquad,
    List<YouthPlayer>? youthSquad,
    this.formation = '4-4-2',
    this.playingStyle = 'Balanced',
    this.teamChemistry = 75,
    this.morale = 75,
    this.matchesPlayed = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.points = 0,
    this.manager = '',
    this.assistantManager = '',
    this.coach = '',
    this.scout = '',
    this.physiotherapist = '',
    this.goalkeeperCoach = '',
    this.youthAcademyLevel = 3,
    this.homegrownPlayers = 0,
    this.youthInvestment = 0,
    List<String>? pastTrophies,
    List<String>? pastLeagues,
    Map<String, int>? records,
  }) : seniorSquad = seniorSquad ?? [],
       youthSquad = youthSquad ?? [],
       pastTrophies = pastTrophies ?? [],
       pastLeagues = pastLeagues ?? [],
       records = records ?? {};

  // ===================== METHODS =====================

  /// Returns the starting XI based on formation and player ratings
  List<Player> getStartingLineup() {
    // Simplified: top 11 OVR players
    final sortedSquad = List<Player>.from(seniorSquad);
    sortedSquad.sort(
      (a, b) => b.calculateOverall().compareTo(a.calculateOverall()),
    );

    return sortedSquad.take(11).toList();
  }

  /// Calculates team strength as average OVR of starting XI + chemistry
  double calculateTeamStrength() {
    final lineup = getStartingLineup();
    if (lineup.isEmpty) return 0;

    double avgOvr =
        lineup.map((p) => p.calculateOverall()).reduce((a, b) => a + b) /
        lineup.length;
    return (avgOvr * 0.7 + teamChemistry * 0.3).clamp(0, 100);
  }

  /// Apply weekly updates (morale, fitness, etc.)
  void applyWeeklyUpdates() {
    // Morale tends to stabilize
    morale = (morale * 0.95 + 5).clamp(0, 100);

    // Update youth growth
    for (var yp in youthSquad) {
      yp.applyGrowth();
    }

    // Update fitness/form for all senior players slightly
    for (var p in seniorSquad) {
      p.form = (p.form + 1).clamp(0, 100);
      p.morale = (p.morale + 0.5).clamp(0, 100);
    }
  }

  /// Generate new youth players for the academy
  /// Called at season start or intake date
  void generateYouthPlayers({int count = 3}) {
    for (int i = 0; i < count; i++) {
      final youth = YouthPlayer(
        id: 'Y-${DateTime.now().millisecondsSinceEpoch}-$i',
        name: 'Youth Player ${youthSquad.length + 1}',
        age: 15 + (i % 3), // 15–17
        nationality: country,
        countryOfBirth: country,
        position: Player.randomPosition(),
        squadNumber: 90 + youthSquad.length + i, // academy numbers
        preferredFoot: (i % 2 == 0) ? 'Right' : 'Left',
        potential: 60 + (youthAcademyLevel * 5) + (i % 10),
        growthRate: 0.8 + (youthAcademyLevel * 0.1),
        academyClub: name,
        homegrown: true,
      );

      youthSquad.add(youth);
    }
  }

  double _average(
    num Function(Player p) selector, {
    bool ignoreUnavailable = true,
    double fallback = 50,
  }) {
    final players =
        ignoreUnavailable
            ? seniorSquad.where((p) => !p.injured && !p.suspended)
            : seniorSquad;

    if (players.isEmpty) return fallback;

    final total = players.map(selector).reduce((a, b) => a + b);
    return (total / players.length).clamp(0, 100);
  }

  double get averageStamina => _average((p) => p.stamina);

  double get averageIntelligence => _average((p) => p.intelligence);

  double get averagePhysical => _average((p) => p.physical);

  /// Apply weekly training effects to all players
  void trainPlayers() {
    // Senior squad training
    for (final player in seniorSquad) {
      player.applyWeeklyTraining();
      player.form = (player.form + 0.3).clamp(0, 100);
      player.morale = (player.morale + 0.2).clamp(0, 100);
    }

    // Youth development (stronger growth)
    for (final youth in youthSquad) {
      youth.applyGrowth();
      youth.form = (youth.form + 0.5).clamp(0, 100);
      youth.morale = (youth.morale + 0.4).clamp(0, 100);
    }
  }

  double get averagePassing => _average((p) => p.passing);

  double get averageDribbling => _average((p) => p.dribbling);

  double get averageDefending => _average((p) => p.defending);

  double get averageShooting => _average((p) => p.shooting);

  double get averageVision => _average((p) => p.vision);

  /// Promote youth players to senior squad
  void promoteYouth(int count) {
    final promotable =
        youthSquad.where((y) => !y.promoted).take(count).toList();
    for (var yp in promotable) {
      yp.promote();
      seniorSquad.add(yp);
      homegrownPlayers++;
    }
    youthSquad.removeWhere((y) => y.promoted);
  }

  double get averageForm => _average((p) => p.form, fallback: morale);

  double get averageMorale => _average((p) => p.morale, fallback: morale);

  double get averageFatigue => _average((p) => p.fatigue, fallback: 0);

  /// Update match results and stats
  void updateMatchResult({required int goalsFor, required int goalsAgainst}) {
    matchesPlayed++;
    this.goalsFor += goalsFor;
    this.goalsAgainst += goalsAgainst;

    if (goalsFor > goalsAgainst) {
      wins++;
      points += 3;
    } else if (goalsFor == goalsAgainst) {
      draws++;
      points += 1;
    } else {
      losses++;
    }
  }

  double get averageGoalkeeping =>
      _average((p) => (p.reflexes + p.handling) / 2);

  /// Add a player to the senior squad
  void addPlayer(Player player) {
    seniorSquad.add(player);
  }

  /// Remove a player from the squad
  void removePlayer(Player player) {
    seniorSquad.removeWhere((p) => p.id == player.id);
  }

  /// Add youth player to academy
  void addYouthPlayer(YouthPlayer yp) {
    youthSquad.add(yp);
  }

  /// Calculate average potential of youth squad
  double averageYouthPotential() {
    if (youthSquad.isEmpty) return 0;
    return youthSquad
            .map((y) => y.potential.toDouble())
            .reduce((a, b) => a + b) /
        youthSquad.length;
  }

  /// Apply weekly financial updates for the club
  /// Updates budget, wage budget, and transfer budget
  void applyWeeklyBudgetUpdate() {
    // Example logic: add small income each week
    double weeklyIncome =
        0.05 * clubValue; // 5% of club value as weekly revenue
    double weeklyWages = seniorSquad.fold(
      0,
      (sum, p) => sum + p.salary,
    ); // total weekly wages
    double youthInvestmentCost =
        youthInvestment / 52; // divide yearly youth investment to weekly

    // Update budgets
    budget += weeklyIncome - weeklyWages - youthInvestmentCost;
    transferBudget +=
        0.5 * weeklyIncome; // 50% of weekly income can go to transfers
    wageBudget += 0.3 * weeklyIncome; // 30% of weekly income reserved for wages

    // Ensure budgets never go negative
    budget = budget.clamp(0, double.infinity);
    transferBudget = transferBudget.clamp(0, double.infinity);
    wageBudget = wageBudget.clamp(0, double.infinity);
  }

  /// Convert team to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'league': league,
    'shortName': shortName,
    'emblemUrl': emblemUrl,
    'budget': budget,
    'wageBudget': wageBudget,
    'transferBudget': transferBudget,
    'clubValue': clubValue,
    'formation': formation,
    'playingStyle': playingStyle,
    'teamChemistry': teamChemistry,
    'morale': morale,
    'matchesPlayed': matchesPlayed,
    'wins': wins,
    'draws': draws,
    'losses': losses,
    'goalsFor': goalsFor,
    'goalsAgainst': goalsAgainst,
    'points': points,
    'manager': manager,
    'assistantManager': assistantManager,
    'coach': coach,
    'scout': scout,
    'physiotherapist': physiotherapist,
    'goalkeeperCoach': goalkeeperCoach,
    'youthAcademyLevel': youthAcademyLevel,
    'homegrownPlayers': homegrownPlayers,
    'youthInvestment': youthInvestment,
    'pastTrophies': pastTrophies,
    'pastLeagues': pastLeagues,
    'records': records,
    'seniorSquad': seniorSquad.map((p) => p.toJson()).toList(),
    'youthSquad': youthSquad.map((y) => y.toJson()).toList(),
  };
}

// ---------------------------
// Match-related helpers
// ---------------------------
extension TeamMatchExtensions on Team {
  /// All outfield players (alias for roster)
  List<Player> get players => seniorSquad;

  /// Simple goalkeeper getter (first GK in senior squad)
  Player get goalkeeper => seniorSquad.firstWhere(
    (p) => p.position == 'GK',
    orElse:
        () => Player(
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
