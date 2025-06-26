import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unused_import
import '../../auth/login_screen.dart';
import '../../home/home_screen.dart';
import '../../auth/get_started_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1)); // for nice UX

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    final googleEmail = prefs.getString('google_email');

    if (email != null || googleEmail != null) {
      // User is already logged in
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const GetStartedScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFFF8F3),
      body: Center(
        child: CircularProgressIndicator(color: Colors.brown),
      ),
    );
  }
}
