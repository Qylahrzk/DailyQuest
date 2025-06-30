import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'models/mood_entry.dart';
import 'auth_layout.dart';
import 'screens/splash_screen.dart';

/// ✅ Entry point for DailyQuest app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ✅ Initialize Hive for local storage
    await Hive.initFlutter();
    Hive.registerAdapter(MoodEntryAdapter());

    await Hive.openBox<MoodEntry>('moods');
    await Hive.openBox('userData');
  } catch (e) {
    // Optionally handle errors if Hive/Firebase fail to initialize
    debugPrint('Initialization error: $e');
  }

  runApp(const DailyQuestApp());
}

/// ✅ The main app widget
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
