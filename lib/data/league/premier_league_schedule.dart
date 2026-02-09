import '../../core/models/team.dart';
import '../teams/arsenal.dart';
import '../teams/aston_villa.dart';
import '../teams/bournemouth.dart';
import '../teams/brentford.dart';
import '../teams/brighton.dart';
import '../teams/burnley.dart';
import '../teams/chelsea.dart';
import '../teams/crystal_palace.dart';
import '../teams/everton.dart';
import '../teams/fulham.dart';
import '../teams/leicester.dart';
import '../teams/liverpool.dart';
import '../teams/man_city.dart';
import '../teams/man_utd.dart';
import '../teams/newcastle.dart';
import '../teams/nottingham_forest.dart';
import '../teams/southampton.dart';
import '../teams/tottenham.dart';
import '../teams/west_ham.dart';
import '../teams/wolves.dart';

import '../../core/models/fixture.dart';

class PremierLeagueSchedule {
  static final List<Team> teams = [
    arsenal,
    astonVilla,
    bournemouth,
    brentford,
    brighton,
    burnley,
    chelsea,
    crystalPalace,
    everton,
    fulham,
    leicester,
    liverpool,
    manchesterCity,
    manUnited,
    newcastle,
    nottinghamForest,
    southampton,
    tottenham,
    westHam,
    wolves,
  ];

  /// Generates fixtures programmatically
  static List<Fixture> generateFixtures() {
    List<Fixture> fixtures = [];
    List<Team> roundTeams = List.from(teams);
    int totalWeeks = (teams.length - 1) * 2; // 38 weeks
    int halfSize = teams.length ~/ 2;

    List<Team> teamsCopy = List.from(roundTeams);

    // First half of season (weeks 1–19)
    for (int week = 1; week <= totalWeeks ~/ 2; week++) {
      for (int i = 0; i < halfSize; i++) {
        Team home = teamsCopy[i];
        Team away = teamsCopy[teamsCopy.length - 1 - i];
        int day = 1 + (i % 7); // staggered Mon-Sun

        fixtures.add(Fixture(home: home, away: away, week: week, day: day));
      }
      Team last = teamsCopy.removeLast();
      teamsCopy.insert(1, last);
    }

    // Second half (weeks 20–38) – reverse home/away
    List<Team> secondHalfTeams = List.from(roundTeams);
    for (int week = totalWeeks ~/ 2 + 1; week <= totalWeeks; week++) {
      for (int i = 0; i < halfSize; i++) {
        Team home = secondHalfTeams[teamsCopy.length - 1 - i];
        Team away = secondHalfTeams[i];
        int day = 1 + (i % 7);

        fixtures.add(Fixture(home: home, away: away, week: week, day: day));
      }
      Team last = secondHalfTeams.removeLast();
      secondHalfTeams.insert(1, last);
    }

    return fixtures;
  }
}
