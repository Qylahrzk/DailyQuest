import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/mood_entry.dart';
import '../../data/mood_dao.dart';
import 'mood_diary_form.dart'; // Make sure this import is correct

class MoodDiaryScreen extends StatefulWidget {
  const MoodDiaryScreen({super.key});

  @override
  State<MoodDiaryScreen> createState() => _MoodDiaryScreenState();
}

class _MoodDiaryScreenState extends State<MoodDiaryScreen> {
  List<MoodEntry> _entries = [];

  int _selectedMonth = DateTime.now().month;
  final int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final data = await MoodDao.getAll();
    setState(() => _entries = data);
  }

  List<MoodEntry> get filteredEntries => _entries.where((entry) {
        return entry.timestamp.year == _selectedYear &&
            entry.timestamp.month == _selectedMonth;
      }).toList();

  Map<int, MoodEntry?> buildWeekdayMoods(List<MoodEntry> entries) {
    Map<int, MoodEntry?> result = {
      1: null,
      2: null,
      3: null,
      4: null,
      5: null,
      6: null,
      7: null,
    };
    for (var entry in entries) {
      result[entry.timestamp.weekday] = entry;
    }
    return result;
  }

  Future<void> _deleteEntry(int id) async {
    await MoodDao.delete(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Entry deleted")),
    );
    _loadEntries();
  }

  Future<void> _navigateToForm({MoodEntry? entry}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoodDiaryForm(existingEntry: entry),
      ),
    );

    // If form returned true (saved/updated), refresh
    if (result == true) {
      _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekdayMoods = buildWeekdayMoods(filteredEntries);

    final totalWords = filteredEntries.fold<int>(
      0,
      (sum, entry) => sum + entry.wordCount,
    );

    final writingDays = filteredEntries
        .map((e) => e.timestamp.day)
        .toSet()
        .length;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffD38C4F),
        title: const Text(
          "MOOD & DIARY",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffF6D0A7), Color(0xffF7E4CF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // 🔥 Streak panel
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Journal Streak",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          DropdownButton<int>(
                            value: _selectedMonth,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedMonth = val);
                              }
                            },
                            underline: const SizedBox(),
                            items: List.generate(12, (i) {
                              return DropdownMenuItem(
                                value: i + 1,
                                child: Text(
                                  DateFormat.MMMM().format(DateTime(0, i + 1)),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 8),
                          Text('$_selectedYear', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (index) {
                          final weekday = index + 1;
                          final entry = weekdayMoods[weekday];
                          return Column(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: entry != null
                                    ? Colors.brown
                                    : Colors.grey.shade300,
                                child: Icon(
                                  entry != null ? Icons.check : Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat.E().format(DateTime(2025, 6, weekday)),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // 📊 Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatTile("Total journal", filteredEntries.length.toString()),
                      _buildStatTile("Total word", totalWords.toString()),
                      _buildStatTile("Days", writingDays.toString()),
                    ],
                  ),
                ),
              ),

              // 😊 Feeling panel
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => _navigateToForm(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffE58E3E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.emoji_emotions, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "How are you feeling today?",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_right, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),

              // 📘 Diary Entries
              if (filteredEntries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "No diary entries yet.",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredEntries.length,
                  itemBuilder: (_, index) {
                    final entry = filteredEntries[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.brown,
                            child: Text(
                              entry.emoji.isNotEmpty ? entry.emoji : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            "Day ${index + 1} · ${entry.mood}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            entry.note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _navigateToForm(entry: entry);
                              } else if (value == 'delete') {
                                _deleteEntry(entry.id!);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Text("Edit")),
                              const PopupMenuItem(value: 'delete', child: Text("Delete")),
                            ],
                          ),
                          onTap: () => _navigateToForm(entry: entry),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
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
  
