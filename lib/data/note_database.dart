// lib/data/note_database.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NoteDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dailyquest.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notebooks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            color INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            notebookId INTEGER,
            content TEXT,
            createdAt TEXT,
            FOREIGN KEY (notebookId) REFERENCES notebooks (id)
          )
        ''');
      },
    );
  }
}
