import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: unused_import
import 'package:sqflite/sqflite.dart';
// ignore: unused_import
import 'package:path/path.dart';

import 'firebase_options.dart';
import 'data/app_database.dart';
import 'navigation/auth_gate.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await AppDatabase.initDb();

    debugPrint("✅ App successfully initialized.");
  } catch (e) {
    debugPrint("⚠️ Initialization error: $e");
  }

  runApp(
    const DailyQuestApp(),
  );
}

class DailyQuestApp extends StatelessWidget {
  const DailyQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'DailyQuest',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: mode,
          home: const AuthGate(),
        );
      },
    );
  }
}

ThemeData _buildLightTheme() {
  return ThemeData(
    primarySwatch: Colors.brown,
    scaffoldBackgroundColor: const Color(0xFFFDF2E3),
    cardColor: Colors.white,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFA15822),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.brown,
    ).copyWith(
      secondary: Colors.brown.shade300,
      surface: Colors.white,
      onSurface: Colors.brown.shade900,
      onPrimary: Colors.white,
    ),
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color.fromARGB(255, 43, 27, 18),
    primaryColor: Colors.brown,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCF722C),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFCF722C),
      secondary: Color(0xFFFAD8A5),
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
    ),
  );
}
