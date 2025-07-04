// lib/data/profile_dao.dart

import 'app_database.dart';

/// ✅ ProfileDao
///
/// Handles saving and retrieving user profile data
/// from the `profile` table in SQLite.
class ProfileDao {
  /// The table name in SQLite
  static const table = 'profile';

  /// 🔹 Save or update profile
  ///
  /// If no profile exists yet, inserts a new record.
  /// Otherwise, updates the existing record.
  ///
  /// [profile] → Map of profile data:
  /// - username
  /// - fullName
  /// - email
  /// - avatarBase64
  /// - xp
  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    final db = await AppDatabase.database;

    // Check if any profile already exists
    final existing = await db.query(table, limit: 1);

    if (existing.isEmpty) {
      /// No record exists → INSERT
      await db.insert(table, profile);
    } else {
      /// Record exists → UPDATE
      await db.update(
        table,
        profile,
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
  }

  /// 🔹 Get profile data
  ///
  /// Returns the first (and only) profile record as a Map,
  /// or `null` if no profile exists.
  static Future<Map<String, dynamic>?> getProfile() async {
    final db = await AppDatabase.database;

    final result = await db.query(table, limit: 1);

    return result.isNotEmpty ? result.first : null;
  }
}
