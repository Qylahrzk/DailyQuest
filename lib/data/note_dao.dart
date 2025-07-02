import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NoteDao {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'diary.db'),
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            notebookId INTEGER,
            content TEXT,
            createdAt TEXT
          )
        ''');
      },
      version: 1,
    );
    return _db!;
  }

  static Future<List<Map<String, dynamic>>> getNotesByNotebook(int notebookId) async {
    final db = await database;
    return db.query(
      'notes',
      where: 'notebookId = ?',
      whereArgs: [notebookId],
    );
  }

  static Future<int> insertNote(int notebookId, String content, String createdAt) async {
    final db = await database;
    return db.insert('notes', {
      'notebookId': notebookId,
      'content': content,
      'createdAt': createdAt,
    });
  }
}
