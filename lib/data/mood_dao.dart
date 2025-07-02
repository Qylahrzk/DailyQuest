import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/mood_entry.dart';

/// ✅ Data Access Object (DAO) for the `moods` table
///
/// Provides static methods to insert, update, delete, and fetch mood entries
/// from the SQLite database managed by [AppDatabase].
class MoodDao {
  /// 🔹 Insert a new mood entry into the database
  ///
  /// If the entry has a duplicate `id`, it will be replaced.
  static Future<int> insert(MoodEntry entry) async {
    final db = await AppDatabase.database;
    return await db.insert(
      'moods',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 🔹 Update an existing mood entry by its [id]
  ///
  /// Returns the number of rows affected (should be 1 if successful).
  static Future<int> update(MoodEntry entry) async {
    final db = await AppDatabase.database;
    return await db.update(
      'moods',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  /// 🔹 Delete a mood entry by [id]
  ///
  /// Returns the number of rows deleted (should be 1 if successful).
  static Future<int> delete(int id) async {
    final db = await AppDatabase.database;
    return await db.delete(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 🔹 Get all mood entries sorted by `timestamp` (latest first)
  ///
  /// Returns a list of [MoodEntry] objects, or an empty list if none found.
  static Future<List<MoodEntry>> getAll() async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moods',
      orderBy: 'timestamp DESC',
    );

    if (maps.isEmpty) return [];

    return maps.map((e) => MoodEntry.fromMap(e)).toList();
  }

  /// 🔹 Get a specific mood entry by [id]
  ///
  /// Returns a [MoodEntry] if found, otherwise returns `null`.
  static Future<MoodEntry?> getById(int id) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    return MoodEntry.fromMap(maps.first);
  }
}
