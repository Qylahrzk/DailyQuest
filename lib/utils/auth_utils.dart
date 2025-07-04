import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Clears user session info from SQLite table userData.
/// This prevents AuthGate from assuming the user is still logged in.
Future<void> clearUserSession() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'dailyquest.db');
  final db = await openDatabase(path);

  try {
    await db.delete('userData');
    debugPrint("✅ userData table cleared on logout.");
  } catch (e) {
    debugPrint("⚠️ Error clearing userData table: $e");
  }
}
