import 'package:flutter/foundation.dart';
import '../data/app_database.dart';
// ignore: unused_import
import 'package:sqflite/sqflite.dart';

class AchievementService {
  static int _xp = 0;
  static final int _userId = 1; // Change if supporting multiple users

  /// Loads the user's XP from the database
  static Future<void> loadXp() async {
    final db = await AppDatabase.database;
    final result = await db.query(
      'users',
      columns: ['xp'],
      where: 'id = ?',
      whereArgs: [_userId],
    );

    if (result.isNotEmpty) {
      _xp = result.first['xp'] as int;
    } else {
      // New user, insert initial record
      await db.insert('users', {'id': _userId, 'xp': 0});
      _xp = 0;
    }
  }

  /// Adds XP and persists it to the database
  static Future<void> addXp(int points) async {
    _xp += points;

    final db = await AppDatabase.database;
    await db.update(
      'users',
      {'xp': _xp},
      where: 'id = ?',
      whereArgs: [_userId],
    );

    if (kDebugMode) {
      print("XP updated to $_xp");
    }
    checkAchievements();
  }

  /// Checks for unlocked achievements
  static void checkAchievements() {
    if (_xp >= 50) {
      if (kDebugMode) {
        print("Achievement unlocked: Note Taker!");
      }
    }
    if (_xp >= 100) {
      if (kDebugMode) {
        print("Achievement unlocked: Word Wizard!");
      }
      if (kDebugMode) {
        print("Achievement unlocked: Diary Enthusiast!");
      }
    }
    // Add more achievements here
  }

  static int get xp => _xp;
}
