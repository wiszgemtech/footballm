import 'package:flutter/material.dart';
import 'package:footballmanager/state/league_provider.dart';
import 'package:footballmanager/state/match_provider.dart';
import 'package:footballmanager/state/team_provider.dart';
import 'package:provider/provider.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final teamProvider = TeamProvider();
  final leagueProvider = LeagueProvider();
  final matchProvider = MatchProvider();

  await leagueProvider.initLeague(); // ensures teams & fixtures exist
  await matchProvider.loadFixtures(
    leagueProvider.teams,
  ); // populate matchProvider

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: teamProvider),
        ChangeNotifierProvider.value(value: matchProvider),
        ChangeNotifierProvider.value(value: leagueProvider),
      ],
      child: const FootballManagerApp(),
    ),
  );
}
