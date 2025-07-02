import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// ✅ AuthService handles:
/// - Firebase email/password auth
/// - Local SQLite cleanup during sign out
/// - User profile updates
/// - Password resets
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the currently logged-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (valid for Firebase-only login).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// ✅ Sign in with email & password via Firebase.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    dev.log(
      "✅ Firebase login successful: ${userCredential.user?.email}",
      name: 'AuthService',
    );
    return userCredential;
  }

  /// ✅ Create new Firebase account.
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    dev.log(
      "✅ Firebase account created: ${userCredential.user?.email}",
      name: 'AuthService',
    );
    return userCredential;
  }

  /// ✅ Sign out from Firebase AND clear local SQLite data.
  Future<void> signOut() async {
    await _auth.signOut();
    await _clearLocalUserData();
    dev.log(
      "✅ User signed out and local data cleared.",
      name: 'AuthService',
    );
  }

  /// ✅ Sends password reset email.
  Future<void> resetPassword({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(email: email);
    dev.log(
      "✅ Password reset email sent to $email",
      name: 'AuthService',
    );
  }

  /// ✅ Update display name in Firebase profile.
  Future<void> updateUsername({
    required String username,
  }) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(username);
      await currentUser!.reload();
      dev.log(
        "✅ Username updated to $username",
        name: 'AuthService',
      );
    }
  }

  /// ✅ Delete Firebase account (requires re-authentication).
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await _clearLocalUserData();
    dev.log(
      "✅ Firebase account deleted for $email",
      name: 'AuthService',
    );
  }

  /// ✅ Change password after verifying old one.
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
    dev.log(
      "✅ Password updated for $email",
      name: 'AuthService',
    );
  }

  /// ✅ Clear any locally saved user info in SQLite.
  Future<void> _clearLocalUserData() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dailyquest.db');
    final db = await openDatabase(path);

    await db.delete('userData');
    dev.log(
      "✅ Local SQLite userData table cleared.",
      name: 'AuthService',
    );
  }
}
