import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/mood_entry.dart';
import 'package:dailyquest/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register your adapter
  Hive.registerAdapter(MoodEntryAdapter());

  // Open boxes
  await Hive.openBox<MoodEntry>('moods');
  await Hive.openBox('userData'); // for XP, streak, etc.

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
      home: const SplashScreen(),
    );
  }
}
