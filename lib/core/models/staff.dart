/// staff.dart
/// Represents club staff members: coaches, scouts, doctors, assistants, etc.

enum StaffRole {
  headCoach,
  assistantCoach,
  fitnessCoach,
  goalkeeperCoach,
  scout,
  doctor,
  physio,
  manager,
}

class Staff {
  // Basic Info
  String name;
  int age;
  String nationality;

  // Role & Influence
  StaffRole role;
  double experience; // 0-100
  double skill; // general skill rating 0-100
  double influence; // influence on players (morale, form, training) 0-100

  // Contracts & Club
  String clubName;
  int contractYears;
  double salary;

  // Optional: staff image / avatar
  String imageUrl;

  // Optional attributes for AI / advanced features
  double tacticalKnowledge; // affects match tactics 0-100
  double scoutingAbility; // affects youth & transfer scouting 0-100
  double medicalAbility; // affects injury recovery 0-100

  Staff({
    required this.name,
    required this.age,
    required this.nationality,
    required this.role,
    this.experience = 50,
    this.skill = 50,
    this.influence = 50,
    this.clubName = "",
    this.contractYears = 1,
    this.salary = 0,
    this.imageUrl = "",
    this.tacticalKnowledge = 50,
    this.scoutingAbility = 50,
    this.medicalAbility = 50,
  });

  /// Applies weekly influence to a team or player
  void applyInfluence() {
    // Placeholder: real logic applied in training or morale updates
    influence = (influence + experience / 100).clamp(0, 100);
  }

  /// Promote or improve staff skill based on experience
  void trainStaff() {
    skill = (skill + 0.2 * experience / 10).clamp(0, 100);
    tacticalKnowledge = (tacticalKnowledge + 0.1 * experience / 10).clamp(
      0,
      100,
    );
    scoutingAbility = (scoutingAbility + 0.1 * experience / 10).clamp(0, 100);
    medicalAbility = (medicalAbility + 0.1 * experience / 10).clamp(0, 100);
  }

  /// Returns a readable description of staff member
  @override
  String toString() {
    return "$name (${role.name}) - Skill: ${skill.toStringAsFixed(1)}, Influence: ${influence.toStringAsFixed(1)}";
  }
}
