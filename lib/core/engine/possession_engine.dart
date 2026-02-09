import 'player.dart';
import 'youth_player.dart';

/// Represents a football/soccer team
class Team {
  // ===================== BASIC INFO =====================
  String id;
  String name;
  String country;
  String league;
  String shortName;
  String emblemUrl;

  // ===================== FINANCES =====================
  double budget;
  double wageBudget;
  double transferBudget;
  double clubValue;

  // ===================== ROSTER =====================
  List<Player> seniorSquad;
  List<YouthPlayer> youthSquad;

  List<Player> get roster => seniorSquad;

  // ===================== FORMATION & TACTICS =====================
  String formation;
  String playingStyle;
  double teamChemistry;
  double morale;

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
  String coach;
  String scout;
  String physiotherapist;
  String goalkeeperCoach;

  List<String> get staff => [
        manager,
        assistantManager,
        coach,
        scout,
        physiotherapist,
        goalkeeperCoach,
      ];

  // ===================== YOUTH ACADEMY =====================
  int youthAcademyLevel;
  int homegrownPlayers;
  double youthInvestment;

  // ===================== HISTORY & ACHIEVEMENTS =====================
  List<String> pastTrophies;
  List<String> pastLeagues;
  Map<String, int> records;

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
  })  : seniorSquad = seniorSquad ?? [],
        youthSquad = youthSquad ?? [],
        pastTrophies = pastTrophies ?? [],
        pastLeagues = pastLeagues ?? [],
        records = records ?? {};

  // ===================== METHODS =====================

  /// Returns the starting XI based on OVR
  List<Player> getStartingLineup() {
    final sorted = List<Player>.from(seniorSquad);
    sorted.sort((a, b) => b.calculateOverall().compareTo(a.calculateOverall()));
    return sorted.take(11).toList();
  }

  double calculateTeamStrength() {
    final lineup = getStartingLineup();
    if (lineup.isEmpty) return 0;
    double avgOvr = lineup.map((p) => p.calculateOverall()).reduce((a, b) => a + b) / lineup.length;
    return (avgOvr * 0.7 + teamChemistry * 0.3).clamp(0, 100);
  }

  /// Promote youth players
  void promoteYouth(int count) {
    final promotable = youthSquad.where((y) => !y.promoted).take(count).toList();
    for (var yp in promotable) {
      yp.promote();
      seniorSquad.add(yp);
      homegrownPlayers++;
    }
    youthSquad.removeWhere((y) => y.promoted);
  }

  void addPlayer(Player player) => seniorSquad.add(player);

  void removePlayer(Player player) => seniorSquad.removeWhere((p) => p.id == player.id);

  void addYouthPlayer(YouthPlayer yp) => youthSquad.add(yp);

  /// Basic average calculation helper
  double _average(num Function(Player) selector, {double fallback = 50}) {
    final players = seniorSquad.where((p) => !p.injured && !p.suspended);
    if (players.isEmpty) return fallback;
    return (players.map(selector).reduce((a, b) => a + b) / players.length).clamp(0, 100);
  }

  double get averageStamina => _average((p) => p.stamina);
  double get averagePhysical => _average((p) => p.physical);
  double get averageIntelligence => _average((p) => p.intelligence);
  double get averagePassing => _average((p) => p.passing);
  double get averageDribbling => _average((p) => p.dribbling);
  double get averageDefending => _average((p) => p.defending);
  double get averageShooting => _average((p) => p.shooting);
  double get averageVision => _average((p) => p.vision);
  double get averageForm => _average((p) => p.form, fallback: morale);
  double get averageMorale => _average((p) => p.morale, fallback: morale);
  double get averageFatigue => _average((p) => p.fatigue, fallback: 0);
  double get averageGoalkeeping => _average((p) => (p.reflexes + p.handling) / 2);

  Player get goalkeeper =>
      seniorSquad.firstWhere((p) => p.position == 'GK', orElse: () => Player(
        id: 'dummyGK',
        name: 'Dummy GK',
        age: 30,
        nationality: country,
        countryOfBirth: country,
        position: 'GK',
        squadNumber: 1,
        preferredFoot: 'Right',
      ));

  /// Update match result
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
}