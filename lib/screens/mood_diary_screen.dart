import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_entry.dart';

class MoodDiaryScreen extends StatefulWidget {
  const MoodDiaryScreen({super.key});

  @override
  State<MoodDiaryScreen> createState() => _MoodDiaryScreenState();
}

class _MoodDiaryScreenState extends State<MoodDiaryScreen> {
  final moodController = TextEditingController();
  final noteController = TextEditingController();

  final Box<MoodEntry> moodBox = Hive.box<MoodEntry>('moods');

  void addMoodEntry() {
    final mood = moodController.text.trim();
    final note = noteController.text.trim();

    if (mood.isEmpty || note.isEmpty) return;

    final newEntry = MoodEntry(
      mood: mood,
      note: note,
      timestamp: DateTime.now(),
    );

    moodBox.add(newEntry);
    moodController.clear();
    noteController.clear();
    Navigator.pop(context);
  }

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
              decoration: const InputDecoration(labelText: 'Mood'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: addMoodEntry,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void deleteMood(int index) {
    moodBox.deleteAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood & Diary'),
      ),
      body: ValueListenableBuilder(
        valueListenable: moodBox.listenable(),
        builder: (context, Box<MoodEntry> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No entries yet'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final entry = box.getAt(index);
              return ListTile(
                leading: const Icon(Icons.emoji_emotions),
                title: Text(entry?.mood ?? ''),
                subtitle: Text('${entry?.note}\n${entry?.timestamp.toString()}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => deleteMood(index),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddMoodDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
