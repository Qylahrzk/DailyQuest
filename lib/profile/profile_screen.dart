// lib/profile/profile_screen.dart

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '../data/profile_dao.dart';
import '../data/mood_dao.dart';
import '../settings/settings_screen.dart';

/// ✅ ProfileScreen
///
/// Displays user profile info:
/// - avatar
/// - editable name, email
/// - stats (XP, diaries, streak)
/// - achievements
///
/// Handles both:
/// - Firebase email/password login
/// - Google login stored locally in SQLite
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Profile fields
  String? _username;
  String? _fullName;
  String? _email;
  String? _avatarBase64;

  /// Gamification
  int _xp = 0;
  int _level = 1;
  int _totalDiaries = 0;
  int _totalWords = 0;
  int _streak = 0;

  /// For picking new avatar image
  final _picker = ImagePicker();

  /// Achievements list
  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'Diary Newbie',
      'unlocked': false,
      'animation': 'assets/animations/achievement1.json'
    },
    {
      'title': 'Wordsmith',
      'unlocked': false,
      'animation': 'assets/animations/achievement2.json'
    },
    {
      'title': 'Streak Star',
      'unlocked': false,
      'animation': 'assets/animations/achievement3.json'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadStats();
  }

  /// ✅ Loads profile info from either:
  /// - Firebase Auth (email/password users)
  /// - SQLite (Google sign-in users)
  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.providerData.first.providerId == 'password') {
      // If signed in via email/password
      setState(() {
        _email = user.email;
        _username = user.email?.split("@").first;
      });
    } else {
      // Else load from SQLite (Google login or anonymous)
      final profile = await ProfileDao.getProfile();
      if (profile != null) {
        setState(() {
          _username = profile['username'];
          _fullName = profile['fullName'];
          _email = profile['email'];
          _avatarBase64 = profile['avatarBase64'];
          _xp = profile['xp'] ?? 0;
          _level = (_xp ~/ 100) + 1;
        });
      }
    }
  }

  /// ✅ Loads stats from the moods table
  Future<void> _loadStats() async {
    final diaryEntries = await MoodDao.getAll();

    _totalDiaries = diaryEntries.length;
    _totalWords = diaryEntries.fold(
      0,
      (sum, e) => sum + e.note.split(' ').length,
    );
    _streak = _calculateStreak(diaryEntries);

    /// Unlock achievements based on thresholds
    _achievements[0]['unlocked'] = _totalDiaries >= 1;
    _achievements[1]['unlocked'] = _totalWords >= 1000;
    _achievements[2]['unlocked'] = _streak >= 7;

    setState(() {});
  }

  /// ✅ Calculate user streak from diary entries
  int _calculateStreak(List entries) {
    if (entries.isEmpty) return 0;

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 1;
    DateTime previousDate = entries.first.timestamp;

    for (var i = 1; i < entries.length; i++) {
      final diff = previousDate.difference(entries[i].timestamp).inDays;
      if (diff == 1) {
        streak++;
        previousDate = entries[i].timestamp;
      } else if (diff > 1) {
        break;
      }
    }
    return streak;
  }

  /// ✅ Opens gallery to pick a new avatar image
  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);
      setState(() {
        _avatarBase64 = base64Str;
      });
      await _saveProfile();
    }
  }

  /// ✅ Save all profile changes to SQLite
  Future<void> _saveProfile() async {
    await ProfileDao.saveProfile({
      'username': _username,
      'fullName': _fullName,
      'email': _email,
      'avatarBase64': _avatarBase64,
      'xp': _xp,
    });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile saved!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Avatar widget
    final avatarWidget = _avatarBase64 == null
        ? CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          )
        : CircleAvatar(
            radius: 50,
            backgroundImage: MemoryImage(base64Decode(_avatarBase64!)),
          );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffD38C4F),
        title: const Text(
          "PROFILE",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            ),
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// Avatar with edit overlay
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  avatarWidget,
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.brown,
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          /// Editable fields
          _buildEditableField("Username", _username, (value) {
            setState(() {
              _username = value;
            });
            _saveProfile();
          }),
          const SizedBox(height: 8),

          _buildEditableField("Full Name", _fullName, (value) {
            setState(() {
              _fullName = value;
            });
            _saveProfile();
          }),
          const SizedBox(height: 8),

          _buildEditableField("Email", _email, (value) {
            setState(() {
              _email = value;
            });
            _saveProfile();
          }),
          const SizedBox(height: 24),

          /// Level and XP card
          Card(
            color: Colors.brown.shade50,
            child: ListTile(
              leading: const Icon(Icons.stars, color: Colors.brown),
              title: Text("Level $_level"),
              subtitle: Text("XP: $_xp / ${_level * 100}"),
            ),
          ),
          const SizedBox(height: 16),

          /// Stats panel
          Card(
            color: Colors.brown.shade50,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.book, color: Colors.brown),
                  title: Text("Total Diaries: $_totalDiaries"),
                ),
                ListTile(
                  leading: const Icon(Icons.text_fields, color: Colors.brown),
                  title: Text("Total Words: $_totalWords"),
                ),
                ListTile(
                  leading: const Icon(Icons.fireplace, color: Colors.brown),
                  title: Text("Streak: $_streak days"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          /// Achievements
          const Text(
            "Achievements",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),

          ..._achievements.map(
            (ach) => Card(
              child: ListTile(
                leading: ach['unlocked']
                    ? Lottie.asset(
                        ach['animation'],
                        width: 50,
                        repeat: false,
                      )
                    : const Icon(Icons.lock, color: Colors.grey),
                title: Text(ach['title']),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Builds an editable text field
  Widget _buildEditableField(
      String label, String? value, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value?.length ?? 0),
      onChanged: onChanged,
    );
  }
}
