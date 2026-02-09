import 'player.dart';

/// Represents a youth player in the academy system
/// Inherits all properties from Player and adds youth-specific attributes
class YouthPlayer extends Player {
  // Age of the youth player (usually 15–19)
  int age;

  // Training focus (e.g., "Shooting", "Defending", "Physical")
  String trainingFocus;

  // Progression speed modifier (affects skill growth per week/month)
  double growthRate;

  // Academy club (can differ from assigned team)
  String academyClub;

  // Whether the youth player has been promoted to senior squad
  bool promoted;

  // Whether the youth player is a homegrown talent
  bool homegrown;

  YouthPlayer({
    required String id,
    required String name,
    required this.age,
    required String nationality,
    required String countryOfBirth,
    required String position,
    required int squadNumber,
    required String preferredFoot,
    String imageUrl = '',
    String agent = '',
    int contractYears = 3,
    double salary = 0,
    double releaseClause = 0,
    double marketValue = 0,
    String club = '',
    bool isCaptain = false,
    int pace = 50,
    int shooting = 50,
    int passing = 50,
    int dribbling = 50,
    int defending = 50,
    int physical = 50,
    int stamina = 50,
    int technique = 50,
    int vision = 50,
    int leadership = 50,
    int reflexes = 50,
    int handling = 50,
    List<String>? traits,
    int goals = 0,
    int assists = 0,
    int appearances = 0,
    int cleanSheets = 0,
    int yellowCards = 0,
    int redCards = 0,
    int saves = 0,
    int shotsOnTarget = 0,
    int minutesPlayed = 0,
    int manOfTheMatchAwards = 0,
    double morale = 75,
    double form = 75,
    double fatigue = 0,
    bool injured = false,
    int injuryDuration = 0,
    bool suspended = false,
    int potential = 75,
    int development = 50,
    bool isYouth = true,
    int youthYear = 0,
    String scoutingReport = '',
    List<String>? previousClubs,
    List<String>? achievements,
    Map<String, double>? transferHistory,
    this.trainingFocus = "All-round",
    this.growthRate = 1.0,
    this.academyClub = "",
    this.promoted = false,
    this.homegrown = true,
  }) : super(
         id: id,
         name: name,
         age: age,
         nationality: nationality,
         countryOfBirth: countryOfBirth,
         position: position,
         squadNumber: squadNumber,
         preferredFoot: preferredFoot,
         imageUrl: imageUrl,
         agent: agent,
         contractYears: contractYears,
         salary: salary,
         releaseClause: releaseClause,
         marketValue: marketValue,
         club: club,
         isCaptain: isCaptain,
         pace: pace,
         shooting: shooting,
         passing: passing,
         dribbling: dribbling,
         defending: defending,
         physical: physical,
         stamina: stamina,
         technique: technique,
         vision: vision,
         leadership: leadership,
         reflexes: reflexes,
         handling: handling,
         traits: traits,
         goals: goals,
         assists: assists,
         appearances: appearances,
         cleanSheets: cleanSheets,
         yellowCards: yellowCards,
         redCards: redCards,
         saves: saves,
         shotsOnTarget: shotsOnTarget,
         minutesPlayed: minutesPlayed,
         manOfTheMatchAwards: manOfTheMatchAwards,
         morale: morale,
         form: form,
         fatigue: fatigue,
         injured: injured,
         injuryDuration: injuryDuration,
         suspended: suspended,
         potential: potential,
         development: development,
         isYouth: isYouth,
         youthYear: youthYear,
         scoutingReport: scoutingReport,
         previousClubs: previousClubs,
         achievements: achievements,
         transferHistory: transferHistory,
       );

  /// Calculates projected OVR based on current skills and potential
  double projectedOverall() {
    double currentOvr = calculateOverall();

    // Youth growth formula
    double yearsToPeak = (21 - age).toDouble(); // assume peak at 21
    double potentialImpact =
        (potential.toDouble() - currentOvr) * (growthRate / yearsToPeak);

    double projected = (currentOvr + potentialImpact).clamp(0, 100);
    return projected;
  }

  /// Apply growth after training or weekly/monthly updates
  void applyGrowth() {
    // Each skill grows towards potential
    pace =
        (pace + (potential - pace) * 0.05 * growthRate).clamp(0, 100).toInt();
    shooting =
        (shooting + (potential - shooting) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();
    passing =
        (passing + (potential - passing) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();
    dribbling =
        (dribbling + (potential - dribbling) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();
    defending =
        (defending + (potential - defending) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();
    physical =
        (physical + (potential - physical) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();
    stamina =
        (stamina + (potential - stamina) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();
    intelligence =
        (intelligence + (potential - intelligence) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();
    technique =
        (technique + (potential - technique) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();
    vision =
        (vision + (potential - vision) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();
    leadership =
        (leadership + (potential - leadership) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();
    reflexes =
        (reflexes + (potential - reflexes) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();
    handling =
        (handling + (potential - handling) * 0.05 * growthRate)
            .clamp(0, 100)
            .toInt();

    // Update morale/form slightly with growth
    morale = (morale + 0.5).clamp(0, 100);
    form = (form + 0.5).clamp(0, 100);
  }

  /// Promote youth player to senior team
  void promote() {
    promoted = true;
    academyClub = "";
  }

  /// Age the youth player by one year
  void ageOneYear() {
    age++;
    if (age >= 20) growthRate *= 0.5;
  }

  /// Reset form and morale periodically
  void resetFormAndMorale() {
    form = 75;
    morale = 75;
  }

  @override
  String toString() {
    return "$name (Age $age, Pos $position, OVR ${calculateOverall().toStringAsFixed(1)}, POT $potential)";
  }
}
