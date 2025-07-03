import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../data/mood_dao.dart';
import '../navigation/diary_completion_screen.dart';

class MoodDiaryForm extends StatefulWidget {
  final MoodEntry? existingEntry;

  const MoodDiaryForm({
    super.key,
    this.existingEntry,
  });

  @override
  State<MoodDiaryForm> createState() => _MoodDiaryFormState();
}

class _MoodDiaryFormState extends State<MoodDiaryForm> {
  final TextEditingController noteController = TextEditingController();
  final TextEditingController otherGratefulController = TextEditingController();

  String selectedMood = '';
  String selectedEmoji = '';
  String? gratefulPart;
  String currentDateTime = '';

  final List<Map<String, String>> moods = [
    {'emoji': '😄', 'label': 'Happy'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😠', 'label': 'Angry'},
    {'emoji': '😲', 'label': 'Surprised'},
    {'emoji': '😌', 'label': 'Calm'},
    {'emoji': '🤔', 'label': 'Thoughtful'},
    {'emoji': '😇', 'label': 'Grateful'},
    {'emoji': '😱', 'label': 'Scared'},
    {'emoji': '🤯', 'label': 'Stressed'},
    {'emoji': '😴', 'label': 'Tired'},
    {'emoji': '😕', 'label': 'Confused'},
    {'emoji': '🤩', 'label': 'Excited'},
    {'emoji': '😍', 'label': 'Loving'},
    {'emoji': '😎', 'label': 'Cool'},
  ];

  final List<Map<String, dynamic>> gratefulParts = [
    {'label': 'Family', 'icon': Icons.family_restroom},
    {'label': 'Health', 'icon': Icons.favorite},
    {'label': 'Work', 'icon': Icons.work},
    {'label': 'Faith', 'icon': Icons.self_improvement},
    {'label': 'Other', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();

    currentDateTime =
        DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.now());

    if (widget.existingEntry != null) {
      final entry = widget.existingEntry!;
      selectedMood = entry.mood;
      selectedEmoji = entry.emoji;
      noteController.text = entry.note;
    }
  }

  Future<void> saveEntry({bool navigate = true}) async {
    if (selectedMood.isEmpty ||
        noteController.text.trim().isEmpty ||
        gratefulPart == null ||
        (gratefulPart == 'Other' && otherGratefulController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    final wordCount =
        noteController.text.trim().split(RegExp(r'\s+')).length;

    if (widget.existingEntry != null) {
      final updated = widget.existingEntry!.copyWith(
        mood: selectedMood,
        emoji: selectedEmoji,
        note: noteController.text.trim(),
        timestamp: DateTime.now(),
        wordCount: wordCount,
      );
      await MoodDao.update(updated);
    } else {
      final newEntry = MoodEntry(
        mood: selectedMood,
        emoji: selectedEmoji,
        note: noteController.text.trim(),
        timestamp: DateTime.now(),
        wordCount: wordCount,
      );
      await MoodDao.insert(newEntry);
    }

    if (navigate) {
      final allEntries = await MoodDao.getAll();

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DiaryCompletionScreen(
            totalEntries: allEntries.length,
            currentDay: allEntries.length,
          ),
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draft saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAD8A5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingEntry == null ? 'New Entry' : 'Edit Entry',
                style: const TextStyle(
                  color: Color(0xFF4A2B14),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'How are you feeling today?',
                  style: const TextStyle(
                    color: Color(0xFFCF722C),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFCF722C), Color(0xFFFAD8A5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Select Mood Type',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: moods.map((mood) {
                        final isSelected = selectedMood == mood['label'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMood = mood['label']!;
                              selectedEmoji = mood['emoji']!;
                            });
                          },
                          child: Container(
                            width: 90,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFCF722C)
                                    : Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  mood['emoji']!,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mood['label']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFFCF722C)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Color(0xFF4A2B14), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    currentDateTime,
                    style: const TextStyle(
                      color: Color(0xFF4A2B14),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'What part of your life are you grateful for?',
                style: const TextStyle(
                  color: Color(0xFF4A2B14),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: gratefulParts.map((part) {
                  final isSelected = gratefulPart == part['label'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          part['icon'],
                          size: 18,
                          color: isSelected
                              ? const Color(0xFFCF722C)
                              : const Color(0xFF4A2B14),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          part['label'],
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFFCF722C)
                                : const Color(0xFF4A2B14),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        gratefulPart = part['label'];
                      });
                    },
                    selectedColor: Colors.white,
                    backgroundColor:
                        Colors.white.withAlpha((0.3 * 255).round()),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFFCF722C)
                            : Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (gratefulPart == 'Other') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: otherGratefulController,
                  decoration: InputDecoration(
                    hintText: 'Please specify...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              ],
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: noteController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Write your diary here...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => saveEntry(navigate: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCF722C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Draft',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCF722C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCF722C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
