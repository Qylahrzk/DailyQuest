import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';
import '../navigation/splash_screen.dart';
import '../navigation/app_navigation_layout.dart';
import '../auth/get_started_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _hasUserInSQLite() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dailyquest.db');
    final db = await openDatabase(path);

    final List<Map<String, dynamic>> users =
        await db.query('userData', limit: 1);

    return users.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.hasData) {
          // User logged in via Firebase
          return const AppNavigationLayout();
        } else {
          // Firebase not logged in — check SQLite fallback
          return FutureBuilder<bool>(
            future: _hasUserInSQLite(),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState != ConnectionState.done) {
                return const SplashScreen();
              }
              if (asyncSnapshot.data == true) {
                return const AppNavigationLayout();
              } else {
                return const GetStartedScreen();
              }
            },
          );
        }
      },
    );
  }
}
