// lib/settings/settings_screen.dart

import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: false,
            onChanged: (val) {
              // implement theme switch logic
            },
          ),
          SwitchListTile(
            title: const Text("Notifications"),
            value: true,
            onChanged: (val) {
              // implement notifications toggle
            },
          ),
          ListTile(
            title: const Text("Change Password"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Delete Account"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("Log Out"),
            onTap: () {},
          ),
          ListTile(
            title: const Text("About"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
