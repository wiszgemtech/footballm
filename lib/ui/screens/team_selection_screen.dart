import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/team.dart';
import '../../data/league/premier_league_schedule.dart';
import 'home_screen.dart';

class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({super.key});

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  Team? _previewTeam;

  @override
  void initState() {
    super.initState();
    _checkSavedTeam();
  }

  /// Skip this page if a team is already selected
  Future<void> _checkSavedTeam() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('selected_team_name');
    if (savedName != null) {
      final savedTeam = PremierLeagueSchedule.teams.firstWhere(
        (t) => t.name == savedName,
        orElse: () => PremierLeagueSchedule.teams.first,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(selectedTeam: savedTeam),
          ),
        );
      }
    }
  }

  /// Save the selected team and go to HomeScreen
  Future<void> _selectTeam() async {
    if (_previewTeam == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_team_name', _previewTeam!.name);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(selectedTeam: _previewTeam!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teams = PremierLeagueSchedule.teams;

    if (teams.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No teams available",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Choose Your Club"),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // =========================
          // FIFA-style preview
          // =========================
          if (_previewTeam != null) _buildPreview(_previewTeam!),

          // =========================
          // Team list
          // =========================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                final selected = _previewTeam == team;

                return GestureDetector(
                  onTap: () => setState(() => _previewTeam = team),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          selected
                              ? Colors.blueGrey.shade900
                              : Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          selected
                              ? Border.all(
                                color: Colors.greenAccent,
                                width: 1.5,
                              )
                              : null,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shield,
                          color: Colors.white70,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            team.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FIFA-STYLE PREVIEW PANEL
  // ============================================================

  Widget _buildPreview(Team team) {
    final attack = team.averageSkill;
    final midfield = team.averageIntelligence;
    final defense = team.averagePace;
    final overall = ((attack + midfield + defense) / 3).round();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            team.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _ratingRow("ATTACK", attack),
          _ratingRow("MIDFIELD", midfield),
          _ratingRow("DEFENCE", defense),
          const SizedBox(height: 8),
          Text(
            "OVERALL: $overall",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _selectTeam,
              child: const Text(
                "SELECT TEAM",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.black,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.greenAccent,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.round().toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
