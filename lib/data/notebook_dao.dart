// ignore: unused_import
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

/// ✅ Data Access Object for Notebooks
class NotebookDao {
  /// 🔹 Get all notebooks
  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await AppDatabase.database;
    return await db.query('notebooks');
  }

  /// 🔹 Insert new notebook
  static Future<int> insert(String title, int color) async {
    final db = await AppDatabase.database;
    return await db.insert('notebooks', {
      'title': title,
      'color': color,
    });
  }
}
