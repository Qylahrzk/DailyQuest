import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NotebookDao {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'diary.db'),
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE notebooks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            color INTEGER
          )
        ''');
      },
      version: 1,
    );
    return _db!;
  }

  static Future<List<Map<String, dynamic>>> getAllNotebooks() async {
    final db = await database;
    return db.query('notebooks');
  }

  static Future<int> insertNotebook(String title, int color) async {
    final db = await database;
    return db.insert('notebooks', {
      'title': title,
      'color': color,
    });
  }

  static insert(String trim, int value) {}

  static getAll() {}
}
