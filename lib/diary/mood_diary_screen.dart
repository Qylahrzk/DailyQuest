import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/mood_entry.dart';

/// 📄 MoodDiaryScreen
///
/// Displays and manages mood and diary entries stored in Hive.
/// Allows users to add, delete, and view diary entries.
class MoodDiaryScreen extends StatefulWidget {
  const MoodDiaryScreen({super.key});

  @override
  State<MoodDiaryScreen> createState() => _MoodDiaryScreenState();
}

class _MoodDiaryScreenState extends State<MoodDiaryScreen> {
  /// Controllers for user input
  final moodController = TextEditingController();
  final noteController = TextEditingController();

  /// Hive box reference
  late final Box<MoodEntry> moodBox;

  @override
  void initState() {
    super.initState();
    moodBox = Hive.box<MoodEntry>('moods');
  }

  /// ➕ Adds a new mood entry to Hive
  void addMoodEntry() {
    final mood = moodController.text.trim();
    final note = noteController.text.trim();

    if (mood.isEmpty || note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields.')),
      );
      return;
    }

    final newEntry = MoodEntry(
      mood: mood,
      note: note,
      timestamp: DateTime.now(),
    );

    moodBox.add(newEntry);

    moodController.clear();
    noteController.clear();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry added successfully!')),
    );
  }

  /// Shows dialog for adding a new mood entry
  void showAddMoodDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Mood Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: moodController,
              decoration: const InputDecoration(
                labelText: 'Mood',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
            ),
            onPressed: addMoodEntry,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Deletes an entry by index
  void deleteMood(int index) {
    moodBox.deleteAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood & Diary'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: moodBox.listenable(),
        builder: (context, Box<MoodEntry> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                'No diary entries yet.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final entry = box.getAt(index);

              if (entry == null) {
                return const SizedBox(); // Defensive null check
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.brown.shade200,
                    child: Text(
                      entry.mood.isNotEmpty
                          ? entry.mood[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    entry.mood,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '''
${DateFormat.yMMMEd().add_jm().format(entry.timestamp)}
${entry.note}
''',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteMood(index),
                  ),
                  onTap: () {
                    // Optional: add edit logic here in the future
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        shape: const CircleBorder(),
        onPressed: showAddMoodDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
