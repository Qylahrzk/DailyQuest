import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/mood_entry.dart';

/// 📖 DiaryScreen
///
/// A screen where users can:
/// - Add new diary entries (mood + note)
/// - Edit existing entries
/// - Delete entries
/// - View all past entries
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  /// Text controllers for mood and note fields
  final _moodController = TextEditingController();
  final _noteController = TextEditingController();

  /// Reference to Hive box
  late final Box<MoodEntry> _moodBox;

  @override
  void initState() {
    super.initState();
    _moodBox = Hive.box<MoodEntry>('moods');
  }

  /// Show modal bottom sheet to add or edit a diary entry
  void _showForm({MoodEntry? entry}) {
    if (entry != null) {
      // Editing existing entry
      _moodController.text = entry.mood;
      _noteController.text = entry.note;
    } else {
      _clearForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _moodController,
                decoration: const InputDecoration(
                  labelText: 'Mood',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Diary Entry',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final mood = _moodController.text.trim();
                  final note = _noteController.text.trim();

                  if (mood.isEmpty || note.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill in both mood and diary entry."),
                      ),
                    );
                    return;
                  }

                  if (entry != null) {
                    // Update existing entry
                    entry
                      ..mood = mood
                      ..note = note
                      ..timestamp = DateTime.now();
                    await entry.save();
                  } else {
                    // Add new entry
                    final newEntry = MoodEntry(
                      mood: mood,
                      note: note,
                      timestamp: DateTime.now(),
                    );
                    await _moodBox.add(newEntry);
                  }

                  _clearForm();

                  if (!context.mounted) return;
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: Text(entry != null ? 'Update Entry' : 'Add Entry'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Delete entry at the given index
  void _deleteEntry(int index) {
    _moodBox.deleteAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Entry deleted")),
    );
  }

  /// Clear the form fields
  void _clearForm() {
    _moodController.clear();
    _noteController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entries'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: _moodBox.listenable(),
        builder: (context, Box<MoodEntry> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                "No diary entries yet.",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final entry = box.getAt(index)!;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
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
                    "${DateFormat.yMMMEd().add_jm().format(entry.timestamp)}\n${entry.note}",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.brown),
                        onPressed: () => _showForm(entry: entry),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteEntry(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        shape: const CircleBorder(),
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}