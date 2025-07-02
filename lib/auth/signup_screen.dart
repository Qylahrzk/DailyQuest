import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../home/home_screen.dart';
import 'auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

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
    final path = join(dbPath, 'dailyquest.db');
    _db = await openDatabase(path);
  }

  /// ✅ Register new user with Firebase Auth (email & password)
  void signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text("Passwords do not match.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final cred = await auth.createAccount(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _saveUserToSQLite(
        email: cred.user?.email ?? '',
        displayName: fullNameController.text.trim(),
        photoUrl: '',
        provider: 'firebase',
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context as BuildContext,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text("Sign-up failed: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ✅ Save user data into SQLite
  Future<void> _saveUserToSQLite({
    required String email,
    required String displayName,
    required String photoUrl,
    required String provider,
  }) async {
    if (_db == null) return;

    await _db!.delete('userData');

    await _db!.insert('userData', {
      'uid': null,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'provider': provider,
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
                Image.asset('assets/images/moodchipi.png', height: 150),
                const SizedBox(height: 16),
                const Text(
                  'Let’s get started!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                /// ✅ Full Name
                TextFormField(
                  controller: fullNameController,
                  validator: (val) => val!.trim().isEmpty
                      ? 'Enter your full name or username'
                      : null,
                  decoration: InputDecoration(
                    hintText: 'Full Name or Username',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

                /// ✅ Confirm Password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  validator: (val) => val!.length < 6
                      ? 'Please confirm your password'
                      : null,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.brown,
                      ),
                      onPressed: () {
                        setState(() {
                          showConfirmPassword = !showConfirmPassword;
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

                /// ✅ Sign Up Button
                ElevatedButton(
                  onPressed: isLoading ? null : signUp,
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
                          'SIGN UP',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Log In",
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
