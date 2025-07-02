import 'package:dailyquest/navigation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'firebase_options.dart';
import 'auth/auth_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _initLocalDatabase();
  } catch (e) {
    debugPrint('Initialization error: $e');
  }

  runApp(const DailyQuestApp());
}

Future<void> _initLocalDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'dailyquest.db');

  await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE moods (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mood TEXT NOT NULL,
          note TEXT NOT NULL,
          timestamp TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE userData (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uid TEXT,
          email TEXT,
          displayName TEXT,
          photoUrl TEXT,
          provider TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE todos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          dueDate TEXT,
          priority INTEGER DEFAULT 1,
          isCompleted INTEGER NOT NULL DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          content TEXT,
          createdAt TEXT
        )
      ''');
    },
  );

  debugPrint("✅ SQLite DB initialized.");
}

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
      home: const AuthLayout(
        pageIfNotConnected: SplashScreen(),
      ),
    );
  }
}
