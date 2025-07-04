import 'package:dailyquest/notes/achievement_service.dart';
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/mood_entry.dart';

/// ✅ Data Access Object (DAO) for the `moods` table
///
/// Handles database operations:
/// - insert new moods
/// - update moods
/// - delete moods
/// - fetch all moods or single moods
/// - adds XP when inserting moods
class MoodDao {
  /// 🔹 Insert a new mood entry into the database
  ///
  /// - Saves a mood entry into the `moods` table
  /// - Adds +10 XP via AchievementService
  ///
  /// If a record with the same `id` exists, it will be replaced.
  static Future<int> insert(MoodEntry entry) async {
    final db = await AppDatabase.database;

    final id = await db.insert(
      'moods',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Award XP for writing a diary entry
    await AchievementService.addXp(10);

    return id;
  }

  /// 🔹 Update an existing mood entry by ID
  ///
  /// - Finds the mood with matching [entry.id]
  /// - Updates mood, note, timestamp, etc.
  ///
  /// Returns:
  /// - Number of rows affected (1 if successful)
  static Future<int> update(MoodEntry entry) async {
    final db = await AppDatabase.database;
    return await db.update(
      'moods',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// 🔹 Delete a mood entry by ID
  ///
  /// Returns:
  /// - Number of rows deleted (1 if successful)
  static Future<int> delete(int id) async {
    final db = await AppDatabase.database;
    return await db.delete(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 🔹 Fetch all mood entries (sorted by most recent first)
  ///
  /// Returns:
  /// - A list of [MoodEntry] or an empty list
  static Future<List<MoodEntry>> getAll() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moods',
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  /// 🔹 Fetch a single mood entry by its [id]
  ///
  /// Returns:
  /// - A [MoodEntry] if found
  /// - `null` if no matching record exists
  static Future<MoodEntry?> getById(int id) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return MoodEntry.fromMap(maps.first);
  }
}
