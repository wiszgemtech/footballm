import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/match_state.dart';
import '../../core/models/team.dart';
import '../../core/engine/match_engine.dart';
import '../../state/match_provider.dart';
import '../../state/team_provider.dart';
import '../../state/league_provider.dart';
import '../widgets/scoreboard_widget.dart';
import '../widgets/commentary_widget.dart';
import '../widgets/stats_panel.dart';

enum MatchPhase { preMatch, firstHalf, halfTime, secondHalf, fullTime }

class MatchScreen extends StatefulWidget {
  final Team home;
  final Team away;

  const MatchScreen({super.key, required this.home, required this.away});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late MatchState match;
  Timer? timer;
  MatchPhase phase = MatchPhase.preMatch;
  List<String> commentaryHistory = [];

  @override
  void initState() {
    super.initState();
    match = MatchState(
      home: widget.home,
      away: widget.away,
      possession: widget.home,
    );
    commentaryHistory.add("Match ready. Press Start Match.");
  }

  void _startFirstHalf() {
    phase = MatchPhase.firstHalf;
    commentaryHistory.add("Kick-off!");
    _startTimer();
    setState(() {});
  }

  void _startSecondHalf() {
    phase = MatchPhase.secondHalf;
    match.switchPossession();
    commentaryHistory.add("Second half underway!");
    _startTimer();
    setState(() {});
  }

  void _startTimer() {
    const tickDuration = Duration(milliseconds: 300);

    timer = Timer.periodic(tickDuration, (t) {
      if (phase == MatchPhase.firstHalf && match.minute >= 45) {
        t.cancel();
        phase = MatchPhase.halfTime;
        commentaryHistory.add("HALF TIME");
        setState(() {});
        return;
      }

      if (phase == MatchPhase.secondHalf && match.isFinished()) {
        t.cancel();
        phase = MatchPhase.fullTime;
        commentaryHistory.add(
          "FULL TIME: ${match.home.name} ${match.homeGoals} - ${match.awayGoals} ${match.away.name}",
        );
        _updateProviders();
        setState(() {});
        return;
      }

      MatchEngine.tick(match, (text) {
        commentaryHistory.add(text);
        if (commentaryHistory.length > 6) commentaryHistory.removeAt(0);
      });

      setState(() {});
    });
  }

  void _finishMatch() {
    timer?.cancel();
    Navigator.pop(context);
  }

  void _updateProviders() {
    final leagueProvider = context.read<LeagueProvider>();
    final matchProvider = context.read<MatchProvider>();
    final teamProvider = context.read<TeamProvider>();

    // Update teams in provider
    teamProvider.updateTeam(match.home);
    teamProvider.updateTeam(match.away);

    // Mark fixture as played
    final fixture = matchProvider.nextFixtureForTeam(match.home);
    if (fixture != null) {
      fixture.play(homeScore: match.homeGoals, awayScore: match.awayGoals);
    }

    // Refresh league table and fixtures
    leagueProvider.initLeague();
    matchProvider.loadFixtures(leagueProvider.teams);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${match.home.name} vs ${match.away.name}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ⚡ Updated: pass MatchState directly
            ScoreboardWidget(match: match),
            const SizedBox(height: 16),

            Expanded(
              flex: 2,
              child: CommentaryWidget(commentary: commentaryHistory),
            ),
            const SizedBox(height: 16),

            _buildControlButton(),
            const SizedBox(height: 16),

            // ⚡ Updated: pass Team objects directly
            Expanded(
              flex: 1,
              child: StatsPanel(home: match.home, away: match.away),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton() {
    String text;
    VoidCallback? action;

    switch (phase) {
      case MatchPhase.preMatch:
        text = "Start Match";
        action = _startFirstHalf;
        break;
      case MatchPhase.halfTime:
        text = "Start Second Half";
        action = _startSecondHalf;
        break;
      case MatchPhase.fullTime:
        text = "Finish Match";
        action = _finishMatch;
        break;
      default:
        text = "Match in Progress";
        action = null;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: action, child: Text(text)),
    );
  }
}
