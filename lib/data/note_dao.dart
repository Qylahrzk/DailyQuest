import 'package:dailyquest/notes/achievement_service.dart';
// ignore: unused_import
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

/// ✅ Data Access Object (DAO) for the `notes` table
///
/// Handles all database operations for notes:
/// - fetching notes
/// - creating notes
/// - updating notes
/// - deleting notes
///
/// Notes are stored as JSON (Zefyr format) in the `content` column.
class NoteDao {
  /// 🔹 Fetch all notes belonging to a single notebook
  ///
  /// Returns a list of maps:
  /// ```dart
  /// [
  ///   {id: 1, notebookId: 2, content: "...", createdAt: "..."},
  ///   ...
  /// ]
  /// ```
  /// Ordered newest first.
  static Future<List<Map<String, dynamic>>> getNotesByNotebook(
      int notebookId) async {
    final db = await AppDatabase.database;

    return await db.query(
      'notes',
      where: 'notebookId = ?',
      whereArgs: [notebookId],
      orderBy: 'createdAt DESC',
    );
  }

  /// 🔹 Insert a new note into the database
  ///
  /// - [notebookId]: ID of the notebook this note belongs to
  /// - [content]: JSON string of the note's Zefyr document
  /// - [createdAt]: ISO8601 timestamp
  ///
  /// Returns:
  /// - The inserted row ID.
  ///
  /// This also awards +15 XP to the user.
  static Future<int> insertNote(
    int notebookId,
    String content,
    String createdAt,
  ) async {
    final db = await AppDatabase.database;

    final id = await db.insert(
      'notes',
      {
        'notebookId': notebookId,
        'content': content,
        'createdAt': createdAt,
      },
    );

    // Award XP for writing a note
    await AchievementService.addXp(15);

    return id;
  }

  /// 🔹 Delete a single note by its ID
  ///
  /// Returns:
  /// - Number of rows deleted (should be 1).
  static Future<int> deleteNote(int noteId) async {
    final db = await AppDatabase.database;

    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  /// 🔹 Update an existing note
  ///
  /// Use this when implementing note editing.
  ///
  /// - [noteId]: ID of the note to update
  /// - [content]: new JSON string for the note
  /// - [updatedAt]: timestamp in ISO8601 format
  ///
  /// Returns:
  /// - Number of rows updated (should be 1).
  static Future<int> updateNote(
    int noteId,
    String content,
    String updatedAt,
  ) async {
    final db = await AppDatabase.database;

    return await db.update(
      'notes',
      {
        'content': content,
        'createdAt': updatedAt,
      },
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }
}
