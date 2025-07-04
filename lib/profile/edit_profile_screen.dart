// lib/profile/edit_profile_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/profile_dao.dart';

/// ✅ EditProfileScreen
///
/// Allows users to:
/// - edit username, full name, and email
/// - change their avatar
/// - save changes back to SQLite
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  /// Controllers for text fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  /// Holds the avatar as Base64 string
  String? _avatarBase64;

  /// Image picker for selecting avatar
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// ✅ Loads existing profile data from SQLite
  ///
  /// Populates:
  /// - username
  /// - full name
  /// - email
  /// - avatar image
  Future<void> _loadProfile() async {
    final profile = await ProfileDao.getProfile();
    if (profile != null) {
      setState(() {
        _usernameController.text = profile['username'] ?? "";
        _fullNameController.text = profile['fullName'] ?? "";
        _emailController.text = profile['email'] ?? "";
        _avatarBase64 = profile['avatarBase64'];
      });
    }
  }

  /// ✅ Allows user to pick a new avatar from gallery
  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _avatarBase64 = base64Encode(bytes);
      });
    }
  }

  /// ✅ Saves updated profile to SQLite
  ///
  /// Called:
  /// - when tapping save button in AppBar
  /// - when pressing Save Changes button
  Future<void> _saveProfile() async {
    await ProfileDao.saveProfile({
      'username': _usernameController.text.trim(),
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'avatarBase64': _avatarBase64,
    });

    if (!mounted) return;

    // Pop the screen after saving
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    /// Avatar widget, either:
    /// - default avatar
    /// - loaded image from Base64
    final avatarWidget = _avatarBase64 == null
        ? const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          )
        : CircleAvatar(
            radius: 50,
            backgroundImage: MemoryImage(base64Decode(_avatarBase64!)),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          /// Check icon in app bar to save changes
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// Avatar section with edit overlay
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

          /// Username field
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: "Username",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          /// Full name field
          TextField(
            controller: _fullNameController,
            decoration: const InputDecoration(
              labelText: "Full Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          /// Email field
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          /// Save changes button at bottom
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text("Save Changes"),
            onPressed: _saveProfile,
          ),
        ],
      ),
    );
  }
}
