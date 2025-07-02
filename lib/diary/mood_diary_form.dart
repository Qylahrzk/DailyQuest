import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// ✅ Model class for a mood diary entry
class MoodEntry {
  int? id;
  String mood;
  String note;
  DateTime timestamp;

  MoodEntry({
    this.id,
    required this.mood,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      mood: map['mood'],
      note: map['note'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

/// 📄 MoodDiaryScreen
///
/// Allows users to:
/// - Add new mood + diary notes
/// - View all mood entries
/// - Delete entries
class MoodDiaryScreen extends StatefulWidget {
  const MoodDiaryScreen({super.key});

  @override
  State<MoodDiaryScreen> createState() => _MoodDiaryScreenState();
}

class _MoodDiaryScreenState extends State<MoodDiaryScreen> {
  Database? _db;

  List<MoodEntry> _entries = [];

  final TextEditingController moodController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  Future<void> _openDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dailyquest.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE IF NOT EXISTS moods (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mood TEXT NOT NULL,
            note TEXT NOT NULL,
            timestamp TEXT NOT NULL
          )
        ''');
      },
    );

    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final maps = await _db!.query(
      'moods',
      orderBy: 'timestamp DESC',
    );

    setState(() {
      _entries = maps.map((e) => MoodEntry.fromMap(e)).toList();
    });
  }

  /// ➕ Add a new mood entry to the database
  Future<void> addMoodEntry() async {
    final mood = moodController.text.trim();
    final note = noteController.text.trim();

    if (mood.isEmpty || note.isEmpty) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields.')),
      );
      return;
    }

    final newEntry = MoodEntry(
      mood: mood,
      note: note,
      timestamp: DateTime.now(),
    );

    await _db!.insert(
      'moods',
      newEntry.toMap(),
    );

    moodController.clear();
    noteController.clear();

    if (!mounted) return;
    Navigator.pop(context as BuildContext);

    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      const SnackBar(content: Text('Entry added successfully!')),
    );

    _loadEntries();
  }

  Future<void> deleteMood(int id) async {
    await _db!.delete(
      'moods',
      where: 'id = ?',
      whereArgs: [id],
    );
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      const SnackBar(content: Text('Entry deleted')),
    );
    _loadEntries();
  }

  /// Show a dialog to add a new mood entry
  void showAddMoodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Wanna share how you’re feeling now?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
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
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Diary Entry',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
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

  @override
  void dispose() {
    _db?.close();
    moodController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood & Diary'),
        centerTitle: true,
      ),
      body: _entries.isEmpty
          ? const Center(
              child: Text(
                'No diary entries yet.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];

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
                      onPressed: () => deleteMood(entry.id!),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        shape: const CircleBorder(),
        onPressed: () => showAddMoodDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
