import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import 'signup_screen.dart';
import '../auth/auth_service.dart';
import '../auth/auth_layout.dart';
import '../auth/get_started_screen.dart';

/// ✅ LoginScreen handles both email/password and Google login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final auth = AuthService();

  Database? _db;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  /// ✅ Initialize SQLite database connection
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'dailyquest.db');
    _db = await openDatabase(path);
  }

  /// ✅ Email/password login via Firebase Auth
  void loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await auth.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      // ✅ Navigate back to AuthLayout
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AuthLayout(
            pageIfNotConnected: GetStartedScreen(),
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ Manual Google Sign-In (not via Firebase)
  void loginWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();

      if (account != null) {
        // ✅ Save Google user info into SQLite
        await _saveGoogleUserToSQLite(account);

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const AuthLayout(
              pageIfNotConnected: GetStartedScreen(),
            ),
          ),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google sign-in was cancelled.")),
        );
      }
    } catch (e) {
      if (kDebugMode) print(e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google login failed: $e")),
      );
    }
  }

  /// ✅ Store Google user data into SQLite for future sessions
  Future<void> _saveGoogleUserToSQLite(GoogleSignInAccount account) async {
    if (_db == null) return;

    await _db!.delete('userData');

    await _db!.insert('userData', {
      'uid': null,
      'email': account.email,
      'displayName': account.displayName,
      'photoUrl': account.photoUrl,
      'provider': 'google',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/images/chipmunk.png', height: 150),
                const SizedBox(height: 16),
                const Text(
                  'Welcome back!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                /// ✅ Email
                TextFormField(
                  controller: emailController,
                  validator: (val) => val!.isEmpty || !val.contains('@')
                      ? 'Enter a valid email'
                      : null,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                /// ✅ Password
                TextFormField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  validator: (val) => val!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.brown,
                      ),
                      onPressed: () {
                        setState(() {
                          showPassword = !showPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isLoading ? null : loginWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'LOGIN WITH EMAIL',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: loginWithGoogle,
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text(
                    "Sign in with Google",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  ),
                  child: const Text(
                    "Don’t have an account? Sign Up",
                    style: TextStyle(color: Colors.brown),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
