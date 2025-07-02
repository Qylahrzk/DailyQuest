// lib/data/profile_dao.dart

import 'app_database.dart';

class ProfileDao {
  static const table = 'profile';

  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    final db = await AppDatabase.database;

    final existing = await db.query(table, limit: 1);
    if (existing.isEmpty) {
      await db.insert(table, profile);
    } else {
      await db.update(table, profile, where: 'id = ?', whereArgs: [existing.first['id']]);
    }
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final db = await AppDatabase.database;
    final result = await db.query(table, limit: 1);
    return result.isNotEmpty ? result.first : null;
  }
}
