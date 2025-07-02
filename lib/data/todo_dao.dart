// lib/data/todo_dao.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo.dart';

class TodoDao {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await init();
    return _db!;
  }

  static Future<Database> init() async {
    final path = join(await getDatabasesPath(), 'dailyquest.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            priority TEXT,
            status TEXT,
            date TEXT,
            time TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  static Future<int> insert(Todo todo) async {
    final dbClient = await db;
    return await dbClient.insert('todos', todo.toMap());
  }

  static Future<List<Todo>> getAll() async {
    final dbClient = await db;
    final data = await dbClient.query('todos');
    return data.map((e) => Todo.fromMap(e)).toList();
  }

  static Future<List<Todo>> getByPriority(String priority) async {
    final dbClient = await db;
    final data = await dbClient.query(
      'todos',
      where: 'priority = ?',
      whereArgs: [priority],
    );
    return data.map((e) => Todo.fromMap(e)).toList();
  }

  static Future<List<Todo>> getByDate(String date) async {
    final dbClient = await db;
    final data = await dbClient.query(
      'todos',
      where: 'date = ?',
      whereArgs: [date],
    );
    return data.map((e) => Todo.fromMap(e)).toList();
  }

  static Future<int> update(Todo todo) async {
    final dbClient = await db;
    return await dbClient.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  static Future<int> delete(int id) async {
    final dbClient = await db;
    return await dbClient.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}
