// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'firebase_options.dart';
import 'data/app_database.dart';
import 'navigation/splash_screen.dart';
import 'auth/auth_layout.dart';

/// ✅ Entry point of the DailyQuest app.
Future<void> main() async {
  // Ensures Flutter engine and platform bindings are ready.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ⚠️ ONLY NEEDED ONCE:
    // Uncomment the next line if you change your DB schema:
    //
    // await deleteOldDatabase();

    /// ✅ Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    /// ✅ Initialize SQLite database
    ///
    /// This ensures that:
    /// - moods
    /// - notes
    /// - notebooks
    /// - todos
    /// - profile
    /// - users
    /// tables are created
    await AppDatabase.initDb();

    debugPrint("✅ App successfully initialized.");
  } catch (e) {
    debugPrint("⚠️ Initialization error: $e");
  }

  runApp(const DailyQuestApp());
}

/// ✅ Deletes the existing SQLite DB to force migration.
///
/// - ONLY run this once if you change your database schema.
/// - Otherwise you will lose all data!
Future<void> deleteOldDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'dailyquest.db');
  await deleteDatabase(path);
  debugPrint("✅ Old database deleted to apply new schema.");
}

/// ✅ DailyQuestApp
///
/// Top-level widget:
/// - Sets up global theme
/// - Defines the app’s first screen
/// - Routes to SplashScreen → Auth → Home
class DailyQuestApp extends StatelessWidget {
  const DailyQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFFFF8F3),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.brown).copyWith(
          secondary: Colors.brown.shade300,
        ),
      ),

      /// ✅ Start with AuthLayout:
      ///
      /// - Checks Firebase login state
      /// - Routes:
      ///     - SplashScreen while loading
      ///     - Auth screens if not logged in
      ///     - Home / Dashboard if logged in
      home: const AuthLayout(
        pageIfNotConnected: SplashScreen(),
      ),
    );
  }
}
