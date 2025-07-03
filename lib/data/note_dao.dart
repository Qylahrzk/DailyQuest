// ignore: unused_import
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

/// ✅ Data Access Object for Notes
///
/// This DAO handles all database operations for the `notes` table:
/// - fetching notes for a notebook
/// - creating new notes
/// - updating notes
/// - deleting notes
///
/// Notes are stored as JSON (Zefyr format) in the `content` column.
class NoteDao {
  /// 🔹 Get all notes belonging to a single notebook
  ///
  /// Returns a list of maps:
  /// ```
  /// [
  ///   {id: 1, notebookId: 2, content: "...", createdAt: "..."},
  ///   ...
  /// ]
  /// ```
  ///
  /// Results are ordered newest first.
  static Future<List<Map<String, dynamic>>> getNotesByNotebook(
      int notebookId) async {
    final db = await AppDatabase.database;

    return db.query(
      'notes',
      where: 'notebookId = ?',
      whereArgs: [notebookId],
      orderBy: 'createdAt DESC',
    );
  }

  /// 🔹 Insert a new note into the database
  ///
  /// [notebookId] → the notebook this note belongs to
  /// [content] → JSON string of the note's Zefyr document
  /// [createdAt] → timestamp in ISO8601 format
  ///
  /// Returns the inserted row ID.
  static Future<int> insertNote(
    int notebookId,
    String content,
    String createdAt,
  ) async {
    final db = await AppDatabase.database;

    return db.insert(
      'notes',
      {
        'notebookId': notebookId,
        'content': content,
        'createdAt': createdAt,
      },
    );
  }

  /// 🔹 Delete a single note by its ID
  ///
  /// Returns the number of rows deleted (should be 1).
  static Future<int> deleteNote(int noteId) async {
    final db = await AppDatabase.database;

    return db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  /// 🔹 Update an existing note
  ///
  /// Use this if you implement note editing.
  ///
  /// - [noteId] → ID of the note to update
  /// - [content] → new JSON string for the note
  /// - [updatedAt] → timestamp in ISO8601 format
  ///
  /// Returns the number of rows updated (should be 1).
  static Future<int> updateNote(
    int noteId,
    String content,
    String updatedAt,
  ) async {
    final db = await AppDatabase.database;

    return db.update(
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
