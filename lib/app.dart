import 'package:flutter/material.dart';
import 'package:footballmanager/ui/screens/team_selection_screen.dart';

class FootballManagerApp extends StatelessWidget {
  const FootballManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Manager',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.greenAccent,
        scaffoldBackgroundColor: const Color(0xFF0E0E10),
        fontFamily: 'Roboto',
      ),

      home: TeamSelectionScreen(),
    );
  }
}
