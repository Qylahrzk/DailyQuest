import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:zefyrka/zefyrka.dart';
import 'package:quill_format/quill_format.dart';

import '../data/notebook_dao.dart';
import '../data/note_dao.dart';
import 'note_entry_screen.dart';
import 'scan_note_util.dart';

/// ✅ NotesScreen
/// Displays:
/// - Chipmunk greeting
/// - Search bar
/// - Notebooks carousel
/// - Buttons for writing/scanning notes
/// - XP gamification
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _notebooks = [];
  List<Map<String, dynamic>> _filteredNotebooks = [];
  final TextEditingController _searchController = TextEditingController();
  int _xp = 0;

  @override
  void initState() {
    super.initState();
    _loadNotebooks();
    _searchController.addListener(_filterNotebooks);
  }

  Future<void> _loadNotebooks() async {
    final data = await NotebookDao.getAll();
    setState(() {
      _notebooks = data;
      _filteredNotebooks = data;
    });
  }

  void _filterNotebooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotebooks = _notebooks
          .where((nb) => nb['title'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _createNewNotebook() async {
    final titleController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create New Notebook"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: "Notebook name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                await NotebookDao.insert(
                  titleController.text.trim(),
                  Colors.primaries[
                      _notebooks.length % Colors.primaries.length
                  ].value,
                );
                if (!mounted) return;
                Navigator.pop(context);
                await _loadNotebooks();
              }
            },
            child: const Text("Create"),
          )
        ],
      ),
    );
  }

  void _openNotebook(Map<String, dynamic> notebook) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotebookDetailScreen(notebook: notebook),
      ),
    ).then((_) => _loadNotebooks());
  }

  Future<void> _scanNote() async {
    final scannedText = await scanNoteFromImage();
    if (!mounted) return;

    if (scannedText.isNotEmpty) {
      _increaseXP(5);

      // Wrap scanned text into Zefyrka Delta JSON
      final doc = NotusDocument()..insert(0, scannedText);
      final jsonString = jsonEncode(doc.toJson());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoteEntryScreen(
            notebookId: -1,
            notebookTitle: "Scanned Note",
            notebookColor: Colors.grey.shade300,
            initialText: jsonString,
          ),
        ),
      );
    }
  }

  void _writeNewNote() {
    _increaseXP(2);

    // Prepare a daily prompt as initial Zefyrka document
    final doc = NotusDocument()..insert(0, _dailyPrompt());
    final jsonString = jsonEncode(doc.toJson());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEntryScreen(
          notebookId: -1,
          notebookTitle: "New Note",
          notebookColor: Colors.grey.shade300,
          initialText: jsonString,
        ),
      ),
    );
  }

  void _increaseXP(int amount) {
    setState(() {
      _xp += amount;
    });
  }

  String _dailyPrompt() {
    final prompts = [
      "What made you smile today?",
      "Describe your ideal day off.",
      "Something you're grateful for today?",
      "Write a letter to your future self.",
      "What challenge did you overcome this week?"
    ];
    return prompts[DateTime.now().day % prompts.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Notes"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _createNewNotebook,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Column(
        children: [
          // Chipmunk + XP
          SizedBox(
            height: 150,
            child: Row(
              children: [
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: Lottie.asset('assets/animations/chipmunk.json'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hi adventurer! Ready to jot down your thoughts today?",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "⭐ XP: $_xp",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search notebooks...",
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Notebooks carousel
          SizedBox(
            height: 160,
            child: _filteredNotebooks.isEmpty
                ? const Center(child: Text("No notebooks yet. Tap + to add one!"))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredNotebooks.length,
                    itemBuilder: (_, index) {
                      final nb = _filteredNotebooks[index];
                      return GestureDetector(
                        onTap: () => _openNotebook(nb),
                        child: Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Color(nb['color']),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              nb['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _writeNewNote,
                  icon: const Icon(Icons.edit),
                  label: const Text("Write Note"),
                ),
                ElevatedButton.icon(
                  onPressed: _scanNote,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Scan Note"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// ✅ NotebookDetailScreen
class NotebookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> notebook;

  const NotebookDetailScreen({super.key, required this.notebook});

  @override
  State<NotebookDetailScreen> createState() => _NotebookDetailScreenState();
}

class _NotebookDetailScreenState extends State<NotebookDetailScreen> {
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final data = await NoteDao.getNotesByNotebook(widget.notebook['id']);
    setState(() {
      _notes = data;
    });
  }

  void _addNote() {
    // Create empty Zefyrka document in JSON
    final emptyJson = jsonEncode(NotusDocument().toJson());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEntryScreen(
          notebookId: widget.notebook['id'],
          notebookTitle: widget.notebook['title'],
          notebookColor: Color(widget.notebook['color']),
          initialText: emptyJson,
        ),
      ),
    ).then((_) => _loadNotes());
  }

  void _openNote(Map<String, dynamic> note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEntryScreen(
          notebookId: widget.notebook['id'],
          notebookTitle: widget.notebook['title'],
          notebookColor: Color(widget.notebook['color']),
          initialText: note['content'],
        ),
      ),
    ).then((_) => _loadNotes());
  }

  String _extractPlainText(String jsonContent) {
    try {
      final delta = Delta.fromJson(jsonDecode(jsonContent));
      final doc = NotusDocument.fromDelta(delta);
      return doc.toPlainText().trim();
    } catch (_) {
      return jsonContent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.notebook['title']),
        backgroundColor: Color(widget.notebook['color']),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNote,
          )
        ],
      ),
      body: _notes.isEmpty
          ? const Center(child: Text("No notes yet in this notebook."))
          : ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (_, index) {
                final note = _notes[index];
                final dateStr = note['createdAt'] ?? '';
                final date = dateStr.isNotEmpty
                    ? DateTime.tryParse(dateStr)
                    : null;
                return ListTile(
                  title: Text(
                    _extractPlainText(note['content']).split('\n').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: date != null
                      ? Text(DateFormat.yMMMEd().add_jm().format(date))
                      : null,
                  onTap: () => _openNote(note),
                );
              },
            ),
    );
  }
}
