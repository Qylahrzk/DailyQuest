import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/mood_entry.dart';

/// ✅ Data Access Object (DAO) for the `moods` table
///
/// Handles database operations such as insert, update, delete,
/// and fetching mood entries from SQLite.
class MoodDao {
  /// 🔹 Insert a new mood entry into the database
  ///
  /// If a record with the same `id` exists, it will be replaced.
  static Future<int> insert(MoodEntry entry) async {
    final db = await AppDatabase.database;
    return await db.insert(
      'moods',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 🔹 Update an existing mood entry by ID
  ///
  /// Returns the number of rows affected (1 if successful).
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
  /// Returns number of rows deleted (1 if successful).
  static Future<int> delete(int id) async {
    final db = await AppDatabase.database;
    return await db.delete(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 🔹 Fetch all mood entries (sorted by most recent)
  ///
  /// Returns a list of MoodEntry or an empty list.
  static Future<List<MoodEntry>> getAll() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moods',
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => MoodEntry.fromMap(map)).toList();
  }

  /// 🔹 Fetch a mood entry by ID
  ///
  /// Returns a single MoodEntry or `null` if not found.
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
