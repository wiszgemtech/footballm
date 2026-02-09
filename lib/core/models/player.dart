import 'dart:math';

/// Represents a professional soccer player
class Player {
  // ===================== PERSONAL INFO =====================
  final String id; // Unique identifier
  String name;
  int age;
  String nationality;
  String countryOfBirth;
  String position; // GK, DEF, MID, ATT
  int squadNumber;
  String preferredFoot; // Left, Right, Both
  String imageUrl; // Asset image or network
  String agent; // Player's agent name

  // ===================== CONTRACT & ASSETS =====================
  int contractYears; // Remaining years
  double salary; // Weekly/monthly salary
  double releaseClause; // Optional buyout clause
  double marketValue; // Transfer value in millions
  String club; // Current club/team
  bool isCaptain;

  // ===================== SKILLS =====================
  // Core attributes
  int pace;
  int shooting;
  int passing;
  int dribbling;
  int defending;
  int physical; // Strength,
  int stamina; // stamina
  int intelligence; // stamina
  int technique;
  int vision;
  int leadership;
  int reflexes; // For goalkeepers
  int handling; // For goalkeepers

  // Special traits / skills (expandable)
  List<String> traits; // e.g., "Injury Prone", "Set Piece Specialist"

  // ===================== STATS =====================
  int goals;
  int assists;
  int appearances;
  int cleanSheets; // For goalkeepers/defenders
  int yellowCards;
  int redCards;
  int saves; // For goalkeepers
  int shotsOnTarget;
  int minutesPlayed;
  int manOfTheMatchAwards;

  // ===================== DYNAMIC STATES =====================
  double morale; // 0-100 scale
  double form; // 0-100 scale
  double fatigue; // 0-100, affects performance
  bool injured;
  int injuryDuration; // Minutes/days remaining
  bool suspended;

  // ===================== YOUTH / POTENTIAL =====================
  int potential; // 0-100
  int development; // 0-100 progression level
  bool isYouth;
  int youthYear; // Year generated
  String scoutingReport; // Optional notes from scouts

  // ===================== HISTORY / CAREER =====================
  List<String> previousClubs;
  List<String> achievements; // Trophies, awards
  Map<String, double> transferHistory; // Team name -> transfer fee

  Player? lastPassRecipient;
  double rating = 75;

  // ===================== CONSTRUCTOR =====================
  Player({
    required this.id,
    required this.name,
    required this.age,
    required this.nationality,
    required this.countryOfBirth,
    required this.position,
    required this.squadNumber,
    required this.preferredFoot,
    this.imageUrl = '',
    this.agent = '',
    this.contractYears = 3,
    this.salary = 0,
    this.releaseClause = 0,
    this.marketValue = 0,
    this.club = '',
    this.isCaptain = false,
    this.pace = 50,
    this.shooting = 50,
    this.passing = 50,
    this.dribbling = 50,
    this.defending = 50,
    this.physical = 50,
    this.intelligence = 50,
    this.stamina = 50,
    this.technique = 50,
    this.vision = 50,
    this.leadership = 50,
    this.reflexes = 50,
    this.handling = 50,
    List<String>? traits,
    this.goals = 0,
    this.assists = 0,
    this.appearances = 0,
    this.cleanSheets = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.saves = 0,
    this.shotsOnTarget = 0,
    this.minutesPlayed = 0,
    this.manOfTheMatchAwards = 0,
    this.morale = 75,
    this.form = 75,
    this.fatigue = 0,
    this.injured = false,
    this.injuryDuration = 0,
    this.suspended = false,
    this.potential = 70,
    this.development = 50,
    this.isYouth = false,
    this.youthYear = 0,
    this.scoutingReport = '',
    List<String>? previousClubs,
    List<String>? achievements,
    Map<String, double>? transferHistory,
  }) : traits = traits ?? [],
       previousClubs = previousClubs ?? [],
       achievements = achievements ?? [],
       transferHistory = transferHistory ?? {};

  // ===================== METHODS =====================

  /// Update stats after a match
  void updateStats({
    int goalsScored = 0,
    int assistsMade = 0,
    int minutes = 0,
    int yellow = 0,
    int red = 0,
    int cleanSheet = 0,
    int savesMade = 0,
    int shotsOnTargetMade = 0,
    bool manOfTheMatch = false,
  }) {
    goals += goalsScored;
    assists += assistsMade;
    minutesPlayed += minutes;
    yellowCards += yellow;
    redCards += red;
    cleanSheets += cleanSheet;
    saves += savesMade;
    shotsOnTarget += shotsOnTargetMade;
    if (manOfTheMatch) manOfTheMatchAwards++;
    appearances++;
  }

  /// Apply automatic weekly training progression
  void applyWeeklyTraining() {
    if (injured || suspended) return;

    final rand = Random();

    // Training intensity affected by fatigue
    double intensity = (1 - (fatigue / 120)).clamp(0.4, 1.0);

    // Youth develop faster
    if (isYouth) intensity *= 1.3;

    // Don't grow past potential
    if (calculateOverall() >= potential) return;

    // Small random improvements
    train(
      paceInc: (rand.nextDouble() * intensity).round(),
      shootingInc: (rand.nextDouble() * intensity).round(),
      passingInc: (rand.nextDouble() * intensity).round(),
      dribblingInc: (rand.nextDouble() * intensity).round(),
      defendingInc: (rand.nextDouble() * intensity).round(),
      physicalInc: (rand.nextDouble() * intensity).round(),
      techniqueInc: (rand.nextDouble() * intensity).round(),
      staminaInc: (rand.nextDouble() * intensity).round(),
      intelligenceInc: (rand.nextDouble() * intensity).round(),
      visionInc: (rand.nextDouble() * intensity).round(),
    );

    // Fatigue increases with training
    fatigue = (fatigue + 4 * intensity).clamp(0, 100);

    // Morale slight boost from training
    morale = (morale + 0.3).clamp(0, 100);
  }

  /// Apply fatigue & morale effect on form
  void applyFormMorale() {
    form = ((morale + (100 - fatigue)) / 2).clamp(0, 100);
  }

  /// Train player for skill improvements
  void train({
    int paceInc = 0,
    int shootingInc = 0,
    int passingInc = 0,
    int dribblingInc = 0,
    int defendingInc = 0,
    int physicalInc = 0,
    int techniqueInc = 0,
    int staminaInc = 0,
    int intelligenceInc = 0,
    int visionInc = 0,
    int leadershipInc = 0,
    int reflexesInc = 0,
    int handlingInc = 0,
  }) {
    pace = (pace + paceInc).clamp(0, 100);
    shooting = (shooting + shootingInc).clamp(0, 100);
    passing = (passing + passingInc).clamp(0, 100);
    dribbling = (dribbling + dribblingInc).clamp(0, 100);
    defending = (defending + defendingInc).clamp(0, 100);
    physical = (physical + physicalInc).clamp(0, 100);
    technique = (technique + techniqueInc).clamp(0, 100);
    vision = (vision + visionInc).clamp(0, 100);
    leadership = (leadership + leadershipInc).clamp(0, 100);
    reflexes = (reflexes + reflexesInc).clamp(0, 100);
    handling = (handling + handlingInc).clamp(0, 100);

    // Increment development for youth
    if (isYouth) development = (development + 1).clamp(0, 100);
  }

  /// Age player by 1 year
  void ageOneYear() {
    age++;
    if (isYouth && age >= 21) isYouth = false;
  }

  /// Returns the typical retirement age for the player
  int get retirementAge {
    int baseAge = position.contains("GK") ? 38 : 35;
    // Extend if physically strong
    if (physical > 85) baseAge += 1;
    return baseAge;
  }

  /// Apply injury
  void injure(int duration) {
    injured = true;
    injuryDuration = duration;
    fatigue = (fatigue + 20).clamp(0, 100);
  }

  /// Reduce injury duration each day
  void recoverInjury() {
    if (injured) {
      injuryDuration--;
      if (injuryDuration <= 0) {
        injured = false;
        injuryDuration = 0;
      }
    }
  }

  /// Suspend player
  void suspend(int days) {
    suspended = true;
    injuryDuration = days;
  }

  /// Resume from suspension
  void resumeSuspension() {
    suspended = false;
    injuryDuration = 0;
  }

  static String randomPosition() {
    const positions = [
      'GK',
      'RB',
      'CB',
      'LB',
      'DM',
      'CM',
      'AM',
      'RW',
      'LW',
      'ST',
    ];
    positions.shuffle();
    return positions.first;
  }

  /// Convert player to JSON (for storage)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'nationality': nationality,
    'countryOfBirth': countryOfBirth,
    'position': position,
    'squadNumber': squadNumber,
    'preferredFoot': preferredFoot,
    'imageUrl': imageUrl,
    'agent': agent,
    'contractYears': contractYears,
    'salary': salary,
    'releaseClause': releaseClause,
    'marketValue': marketValue,
    'club': club,
    'isCaptain': isCaptain,
    'skills': {
      'pace': pace,
      'shooting': shooting,
      'passing': passing,
      'dribbling': dribbling,
      'defending': defending,
      'physical': physical,
      'stamina': stamina,
      'intelligence': intelligence,
      'technique': technique,
      'vision': vision,
      'leadership': leadership,
      'reflexes': reflexes,
      'handling': handling,
    },
    'traits': traits,
    'stats': {
      'goals': goals,
      'assists': assists,
      'appearances': appearances,
      'cleanSheets': cleanSheets,
      'yellowCards': yellowCards,
      'redCards': redCards,
      'saves': saves,
      'shotsOnTarget': shotsOnTarget,
      'minutesPlayed': minutesPlayed,
      'manOfTheMatchAwards': manOfTheMatchAwards,
    },
    'morale': morale,
    'form': form,
    'fatigue': fatigue,
    'injured': injured,
    'injuryDuration': injuryDuration,
    'suspended': suspended,
    'potential': potential,
    'development': development,
    'isYouth': isYouth,
    'youthYear': youthYear,
    'scoutingReport': scoutingReport,
    'previousClubs': previousClubs,
    'achievements': achievements,
    'transferHistory': transferHistory,
  };

  /// Load player from JSON
  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    age: json['age'],
    nationality: json['nationality'],
    countryOfBirth: json['countryOfBirth'],
    position: json['position'],
    squadNumber: json['squadNumber'],
    preferredFoot: json['preferredFoot'],
    imageUrl: json['imageUrl'] ?? '',
    agent: json['agent'] ?? '',
    contractYears: json['contractYears'] ?? 3,
    salary: json['salary']?.toDouble() ?? 0,
    releaseClause: json['releaseClause']?.toDouble() ?? 0,
    marketValue: json['marketValue']?.toDouble() ?? 0,
    club: json['club'] ?? '',
    isCaptain: json['isCaptain'] ?? false,
    pace: json['skills']?['pace'] ?? 50,
    shooting: json['skills']?['shooting'] ?? 50,
    passing: json['skills']?['passing'] ?? 50,
    dribbling: json['skills']?['dribbling'] ?? 50,
    defending: json['skills']?['defending'] ?? 50,
    physical: json['skills']?['physical'] ?? 50,
    intelligence: json['skills']?['intelligence'] ?? 50,
    stamina: json['skills']?['stamina'] ?? 50,
    technique: json['skills']?['technique'] ?? 50,
    vision: json['skills']?['vision'] ?? 50,
    leadership: json['skills']?['leadership'] ?? 50,
    reflexes: json['skills']?['reflexes'] ?? 50,
    handling: json['skills']?['handling'] ?? 50,
    traits: List<String>.from(json['traits'] ?? []),
    goals: json['stats']?['goals'] ?? 0,
    assists: json['stats']?['assists'] ?? 0,
    appearances: json['stats']?['appearances'] ?? 0,
    cleanSheets: json['stats']?['cleanSheets'] ?? 0,
    yellowCards: json['stats']?['yellowCards'] ?? 0,
    redCards: json['stats']?['redCards'] ?? 0,
    saves: json['stats']?['saves'] ?? 0,
    shotsOnTarget: json['stats']?['shotsOnTarget'] ?? 0,
    minutesPlayed: json['stats']?['minutesPlayed'] ?? 0,
    manOfTheMatchAwards: json['stats']?['manOfTheMatchAwards'] ?? 0,
    morale: json['morale']?.toDouble() ?? 75,
    form: json['form']?.toDouble() ?? 75,
    fatigue: json['fatigue']?.toDouble() ?? 0,
    injured: json['injured'] ?? false,
    injuryDuration: json['injuryDuration'] ?? 0,
    suspended: json['suspended'] ?? false,
    potential: json['potential'] ?? 70,
    development: json['development'] ?? 50,
    isYouth: json['isYouth'] ?? false,
    youthYear: json['youthYear'] ?? 0,
    scoutingReport: json['scoutingReport'] ?? '',
    previousClubs: List<String>.from(json['previousClubs'] ?? []),
    achievements: List<String>.from(json['achievements'] ?? []),
    transferHistory: Map<String, double>.from(json['transferHistory'] ?? {}),
  );

  /// Calculates the overall rating (OVR) of the player
  /// Takes into account skills, form, morale, and position-specific weighting
  double calculateOverall() {
    double ovr = 0;

    // Position-specific weighting
    if (position.contains("GK")) {
      ovr =
          (reflexes * 0.3) +
          (handling * 0.3) +
          (physical * 0.1) +
          (vision * 0.1) +
          (leadership * 0.2);
    } else if (position.contains("DEF")) {
      ovr =
          (defending * 0.35) +
          (physical * 0.2) +
          (pace * 0.15) +
          (passing * 0.15) +
          (vision * 0.15);
    } else if (position.contains("MID")) {
      ovr =
          (passing * 0.25) +
          (dribbling * 0.2) +
          (vision * 0.2) +
          (shooting * 0.15) +
          (physical * 0.1) +
          (leadership * 0.1);
    } else if (position.contains("ATT")) {
      ovr =
          (shooting * 0.3) +
          (pace * 0.25) +
          (dribbling * 0.2) +
          (physical * 0.1) +
          (passing * 0.1) +
          (vision * 0.05);
    } else {
      // Default weighting for unknown positions
      ovr =
          (pace +
              shooting +
              passing +
              dribbling +
              defending +
              physical +
              technique +
              vision +
              leadership) /
          9;
    }

    // Apply form & morale influence
    ovr *= (0.7 + (form / 300) + (morale / 300));
    // Explanation: form and morale contribute up to ~30% of the total OVR

    return ovr.clamp(0, 100); // Ensure 0-100 scale
  }
}
