import 'package:flutter/material.dart';
import 'package:footballmanager/ui/screens/team_selection_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Football Manager",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Play as guest -> Navigate to HomeScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeamSelectionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.orangeAccent,
              ),
              child: const Text(
                "Play as Guest",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder for Firebase login later
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.greenAccent,
              ),
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
