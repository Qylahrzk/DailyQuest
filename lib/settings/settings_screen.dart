import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart'; // For themeNotifier
import '../navigation/auth_gate.dart'; // To navigate to login screen (GetStarted)
import '../utils/auth_utils.dart'; // Custom helper to clear SQLite session

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Toggle switches
  bool _locationEnabled = true;
  bool _notificationsEnabled = true;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = themeNotifier.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCF722C),
        title: const Text(
          "SETTING",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// GENERAL SECTION
            _buildSectionCard(
              context,
              title: "GENERAL",
              children: [
                SwitchListTile(
                  title: const Text("Location"),
                  value: _locationEnabled,
                  activeColor: colors.primary,
                  onChanged: (val) {
                    setState(() {
                      _locationEnabled = val;
                      // TO-DO: Implement location logic
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text("Notifications"),
                  value: _notificationsEnabled,
                  activeColor: colors.primary,
                  onChanged: (val) {
                    setState(() {
                      _notificationsEnabled = val;
                      // TO-DO: Implement notifications logic
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text("Appearance"),
                  value: _isDarkMode,
                  activeColor: colors.primary,
                  onChanged: (val) {
                    setState(() {
                      _isDarkMode = val;
                      themeNotifier.value =
                          val ? ThemeMode.dark : ThemeMode.light;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// APP INFO SECTION
            _buildSectionCard(
              context,
              title: "APP INFORMATION",
              children: [
                _buildNavTile(
                  icon: Icons.help_outline,
                  text: "Help & Support",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Help & Support clicked.")),
                    );
                  },
                ),
                _buildNavTile(
                  icon: Icons.info_outline,
                  text: "Support",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Support clicked.")),
                    );
                  },
                ),
                _buildNavTile(
                  icon: Icons.info,
                  text: "About",
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "DailyQuest",
                      applicationVersion: "1.0.0",
                      applicationLegalese: "© 2025 DailyQuest Team",
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// ACCOUNT SECTION
            _buildSectionCard(
              context,
              title: "ACCOUNT",
              children: [
                _buildNavTile(
                  icon: Icons.lock_outline,
                  text: "Change Password",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Change Password clicked.")),
                    );
                  },
                ),
                _buildNavTile(
                  icon: Icons.security_outlined,
                  text: "Privacy & Security",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Privacy & Security clicked.")),
                    );
                  },
                ),
                _buildNavTile(
                  icon: Icons.delete_outline,
                  text: "Delete Account",
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Delete Account"),
                        content: const Text(
                            "Are you sure you want to delete your account?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: colors.primary),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                            ),
                            onPressed: () {
                              // TO-DO: Implement delete logic
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Account deleted.")),
                              );
                            },
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _buildNavTile(
                  icon: Icons.logout,
                  text: "Log Out",
                  onTap: _handleLogout,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Handle logout for both Firebase and SQLite
  Future<void> _handleLogout() async {
    try {
      // Optional: Sign out from Google
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();

      // Sign out Firebase
      await FirebaseAuth.instance.signOut();

      // Clear SQLite user session
      await clearUserSession();

      if (!mounted) return;

      // Go back to AuthGate, replacing all routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } catch (e) {
      debugPrint("Logout error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  /// Builds section card container
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFF8D36),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Builds each navigation tile with icon and text
  Widget _buildNavTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.primary),
      title: Text(
        text,
        style: TextStyle(color: colors.onSurface),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colors.primary),
      onTap: onTap,
    );
  }
}
