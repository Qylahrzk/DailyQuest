import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

/// ✅ GetStartedScreen - shown when the user first opens the app.
///
/// - Displays logo + welcome text
/// - Navigates to login screen
class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// ✅ App logo
                SizedBox(
                  height: 200,
                  child: Image.asset(
                    'assets/images/moodchipi.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),

                /// ✅ Heading
                Text(
                  "Welcome to DailyQuest!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                /// ✅ Description
                Text(
                  "Track your moods, journal your thoughts, and level up with XP on your personal growth adventure. 🎯",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 50),

                /// ✅ Get Started button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text(
                      "Get Started",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
