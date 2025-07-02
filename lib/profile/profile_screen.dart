// lib/profile/profile_screen.dart

import 'dart:convert';
// ignore: unused_import
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '../data/profile_dao.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _username;
  String? _fullName;
  String? _email;
  String? _avatarBase64;
  final _picker = ImagePicker();

  /// Dummy achievements tracking.
  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'Diary Newbie',
      'unlocked': true,
      'animation': 'assets/animations/achievement1.json'
    },
    {
      'title': 'Note Master',
      'unlocked': false,
      'animation': 'assets/animations/achievement2.json'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await ProfileDao.getProfile();
    if (profile != null) {
      setState(() {
        _username = profile['username'];
        _fullName = profile['fullName'];
        _email = profile['email'];
        _avatarBase64 = profile['avatarBase64'];
      });
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);
      setState(() {
        _avatarBase64 = base64Str;
      });
      _saveProfile();
    }
  }

  Future<void> _saveProfile() async {
    await ProfileDao.saveProfile({
      'username': _username,
      'fullName': _fullName,
      'email': _email,
      'avatarBase64': _avatarBase64,
    });
  }

  @override
  Widget build(BuildContext context) {
    final avatarWidget = _avatarBase64 == null
        ? CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          )
        : CircleAvatar(
            radius: 50,
            backgroundImage:
                MemoryImage(base64Decode(_avatarBase64!)),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
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
          TextField(
            decoration: const InputDecoration(labelText: "Username"),
            controller: TextEditingController(text: _username)
              ..selection = TextSelection.collapsed(offset: _username?.length ?? 0),
            onChanged: (value) {
              _username = value;
              _saveProfile();
            },
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(labelText: "Full Name"),
            controller: TextEditingController(text: _fullName)
              ..selection = TextSelection.collapsed(offset: _fullName?.length ?? 0),
            onChanged: (value) {
              _fullName = value;
              _saveProfile();
            },
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(labelText: "Email"),
            controller: TextEditingController(text: _email)
              ..selection = TextSelection.collapsed(offset: _email?.length ?? 0),
            onChanged: (value) {
              _email = value;
              _saveProfile();
            },
          ),
          const SizedBox(height: 24),

          const Text(
            "Achievements",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          ..._achievements.map((ach) => Card(
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
              ))
        ],
      ),
    );
  }
}
