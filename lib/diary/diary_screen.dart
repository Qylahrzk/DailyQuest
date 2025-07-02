import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/mood_entry.dart';
import '../../data/mood_dao.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<MoodEntry> _entries = [];

  /// Filters for the streak panel
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  final _moodController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final data = await MoodDao.getAll();
    setState(() {
      _entries = data;
    });
  }

  List<MoodEntry> get filteredEntries {
    return _entries.where((entry) {
      return entry.timestamp.year == _selectedYear &&
             entry.timestamp.month == _selectedMonth;
    }).toList();
  }

  /// Builds a map of weekday => has diary entry (true/false)
  Map<int, bool> buildWeekdayStreak(List<MoodEntry> entries) {
    Map<int, bool> result = {
      1: false,
      2: false,
      3: false,
      4: false,
      5: false,
      6: false,
      7: false,
    };
    for (var entry in entries) {
      result[entry.timestamp.weekday] = true;
    }
    return result;
  }

  void _showForm({MoodEntry? entry}) {
    if (entry != null) {
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
                      const SnackBar(content: Text("Please fill in both fields.")),
                    );
                    return;
                  }

                  if (entry != null) {
                    final updated = entry.copyWith(
                      mood: mood,
                      note: note,
                      timestamp: DateTime.now(),
                    );
                    await MoodDao.update(updated);
                  } else {
                    final newEntry = MoodEntry(
                      mood: mood,
                      note: note,
                      timestamp: DateTime.now(),
                    );
                    await MoodDao.insert(newEntry);
                  }

                  _clearForm();
                  if (!mounted) return;
                  Navigator.pop(context);
                  _loadEntries();
                },
                child: Text(entry != null ? 'Update Entry' : 'Add Entry'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteEntry(int id) async {
    await MoodDao.delete(id);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Entry deleted")),
    );
    _loadEntries();
  }

  void _clearForm() {
    _moodController.clear();
    _noteController.clear();
  }

  @override
  void dispose() {
    _moodController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streakMap = buildWeekdayStreak(filteredEntries);

    final totalWords = filteredEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.note.trim().split(RegExp(r'\s+')).length,
    );

    final writingDays = filteredEntries
        .map((e) => e.timestamp.toLocal().day)
        .toSet()
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Diary Streak Panel
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DropdownButton<int>(
                        value: _selectedMonth,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMonth = value;
                            });
                          }
                        },
                        items: List.generate(12, (index) {
                          return DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text(
                              DateFormat.MMMM().format(DateTime(0, index + 1)),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: _selectedYear,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedYear = value;
                            });
                          }
                        },
                        items: List.generate(10, (index) {
                          final year = DateTime.now().year - index;
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text('$year'),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) {
                      final weekdayName = DateFormat.E().format(
                        DateTime(2025, 6, index + 2),
                      );
                      return Text(
                        weekdayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (index) {
                      final weekday = index + 1;
                      final hasEntry = streakMap[weekday] ?? false;
                      return Icon(
                        hasEntry ? Icons.check_circle : Icons.cancel,
                        color: hasEntry ? Colors.brown : Colors.grey,
                        size: 28,
                      );
                    }),
                  ),
                ],
              ),
            ),

            /// Statistics Panel
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatTile(
                        label: "Total Diaries",
                        value: "${filteredEntries.length}",
                      ),
                      _buildStatTile(
                        label: "Total Words",
                        value: "$totalWords",
                      ),
                      _buildStatTile(
                        label: "Writing Days",
                        value: "$writingDays",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// Diary Entries List
            if (filteredEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "No diary entries yet.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredEntries.length,
                itemBuilder: (context, index) {
                  final entry = filteredEntries[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        "${entry.formattedDate}\n${entry.note}",
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
                            onPressed: () => _deleteEntry(entry.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
