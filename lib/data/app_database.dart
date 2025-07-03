// lib/data/app_database.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// ✅ AppDatabase
///
/// Singleton class responsible for:
/// - Opening the SQLite database
/// - Creating all tables on first run
/// - Providing a shared instance across the entire app
class AppDatabase {
  /// Private database instance
  static Database? _db;

  /// 🔹 Returns a single, shared [Database] instance.
  ///
  /// Opens the database if not already open.
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  /// 🔹 Initializes and opens the SQLite database.
  ///
  /// This:
  /// - Resolves the file path
  /// - Opens the database
  /// - Creates required tables if not existing
  static Future<Database> initDb() async {
    // Get the platform-specific path to store the database
    final dbPath = await getDatabasesPath();

    // Construct the full path to the database file
    final path = join(dbPath, 'dailyquest.db');

    // Open or create the database
    return await openDatabase(
      path,
      version: 2,

      // Called before onCreate, useful for PRAGMA or enabling constraints
      onConfigure: (db) async {
        // Enable foreign key constraints for SQLite
        await db.execute('PRAGMA foreign_keys = ON');
      },

      // Called only if database file does not exist yet
      onCreate: (db, version) async {
        /// ✅ Create moods table
        await db.execute('''
          CREATE TABLE moods (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mood TEXT NOT NULL,
            emoji TEXT,
            note TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            wordCount INTEGER DEFAULT 0
          )
        ''');

        /// ✅ Create users table (Firebase auth data + gamification stats)
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            provider TEXT,
            googleId TEXT,
            email TEXT,
            displayName TEXT,
            photoUrl TEXT,
            xp INTEGER DEFAULT 0,
            streak INTEGER DEFAULT 0
          )
        ''');

        /// ✅ Create notebooks table (for organizing notes)
        await db.execute('''
          CREATE TABLE notebooks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            color INTEGER NOT NULL
          )
        ''');

        /// ✅ Create notes table
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            notebookId INTEGER,
            content TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (notebookId) REFERENCES notebooks (id) ON DELETE CASCADE
          )
        ''');

        /// ✅ Create profile table (user profile info + avatar)
        await db.execute('''
          CREATE TABLE profile (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            fullName TEXT,
            email TEXT,
            avatarBase64 TEXT
          )
        ''');

        /// ✅ Create todos table (to-do tasks) - matching your model
        await db.execute('''
          CREATE TABLE todos (
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

      // Handles database upgrades between versions
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          /// In version 2, we added:
          /// - notebooks
          /// - notes
          /// - profile
          /// - todos (updated schema)

          await db.execute('''
            CREATE TABLE IF NOT EXISTS notebooks (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              color INTEGER NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS notes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              notebookId INTEGER,
              content TEXT NOT NULL,
              createdAt TEXT NOT NULL,
              FOREIGN KEY (notebookId) REFERENCES notebooks (id) ON DELETE CASCADE
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS profile (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT,
              fullName TEXT,
              email TEXT,
              avatarBase64 TEXT
            )
          ''');

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
        }
      },
    );
  }
}
