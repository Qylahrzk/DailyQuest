import 'package:firebase_auth/firebase_auth.dart';

/// Provides all Firebase Auth logic used in DailyQuest.
/// 
/// - Email/password sign-in
/// - Account creation
/// - Password reset
/// - User updates
/// - Re-authentication for sensitive actions
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the currently logged-in user, or null if signed out.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (signed in/out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in an existing user with email and password.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Creates a new user account with email and password.
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs out the current user.
  Future<void> signOut() {
    return _auth.signOut();
  }

  /// Sends a password reset email.
  Future<void> resetPassword({
    required String email,
  }) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  /// Updates the user's display name.
  Future<void> updateUsername({
    required String username,
  }) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(username);
      await currentUser!.reload(); // Refresh user data
    }
  }

  /// Deletes the current user's account after re-authentication.
  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
  }

  /// Changes the user's password after verifying current password.
  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.updatePassword(newPassword);
  }
}
