import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // remove login info

    Navigator.pushAndRemoveUntil(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE0D1),
      appBar: AppBar(
        title: const Text("DailyQuest"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          )
        ],
      ),
      body: const Center(
        child: Text("You're logged in!", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}