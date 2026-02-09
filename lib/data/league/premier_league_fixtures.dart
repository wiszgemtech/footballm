import '../../core/models/fixture.dart';
import 'premier_league_schedule.dart';

class PremierLeagueFixtures {
  /// All fixtures are generated using the schedule
  static final List<Fixture> allFixtures =
      PremierLeagueSchedule.generateFixtures();
}
