import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/mood_entry.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'app_navigation_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(MoodEntryAdapter());

  // ✅ Open Hive boxes
  await Hive.openBox<MoodEntry>('moods');
  await Hive.openBox('userData'); // For XP, streak, etc.

  runApp(const DailyQuestApp());
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
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      // ✅ Show splash if not logged in, else show bottom navigation layout
      home: FirebaseAuth.instance.currentUser == null
          ? const SplashScreen()
          : const AppNavigationLayout(), // 👈 This is your new dashboard layout
    );
  }
}