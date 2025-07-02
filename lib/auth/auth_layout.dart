import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../navigation/app_loading_page.dart';
import '../auth/get_started_screen.dart';
import '../navigation/app_navigation_layout.dart';

/// ✅ Global Firebase auth instance
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

/// ✅ AuthLayout = Hybrid Auth Gate
/// - Listens to Firebase auth changes
/// - Falls back to SQLite session check
/// - Shows splash while checking
/// - Navigates to AppNavigationLayout if logged in
/// - Navigates to GetStartedScreen if logged out
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    this.pageIfNotConnected,
  });

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _firebaseAuth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingPage();
        }

        if (snapshot.hasData) {
          // ✅ Firebase user is logged in
          return const AppNavigationLayout();
        } else {
          // ✅ Firebase user is logged out → check SQLite
          return FutureBuilder<bool>(
            future: _checkSqliteSession(),
            builder: (context, sqliteSnapshot) {
              if (sqliteSnapshot.connectionState == ConnectionState.waiting) {
                return const AppLoadingPage();
              }

              if (sqliteSnapshot.data == true) {
                return const AppNavigationLayout();
              } else {
                return pageIfNotConnected ?? const GetStartedScreen();
              }
            },
          );
        }
      },
    );
  }

  /// ✅ Check local SQLite table for saved Google user session
  Future<bool> _checkSqliteSession() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'dailyquest.db');
      final db = await openDatabase(path);

      final users = await db.query('userData', limit: 1);
      return users.isNotEmpty;
    } catch (e) {
      debugPrint("SQLite check error: $e");
      return false;
    }
  }
}
