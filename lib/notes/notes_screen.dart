import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

import '../data/notebook_dao.dart';
import '../data/note_dao.dart';
import 'note_entry_screen.dart';
import 'scan_note_util.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _notebooks = [];

  @override
  void initState() {
    super.initState();
    _loadNotebooks();
  }

  Future<void> _loadNotebooks() async {
    final data = await NotebookDao.getAll();
    setState(() {
      _notebooks = data;
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
                  // ignore: deprecated_member_use
                  Colors.primaries[_notebooks.length % Colors.primaries.length].value,
                );
                if (context.mounted) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  await _loadNotebooks();
                }
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
    ).then((_) {
      _loadNotebooks();
    });
  }

  Future<void> _scanNote() async {
    final scannedText = await scanNoteFromImage();
    if (!mounted) return;

    if (scannedText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoteEntryScreen(
            notebookId: -1, // using -1 as dummy id for scanned notes
            notebookTitle: "Scanned Note",
            notebookColor: Colors.grey.shade300,
            initialText: scannedText,
          ),
        ),
      );
    }
  }

  void _writeNewNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEntryScreen(
          notebookId: -1, // using -1 as dummy id for single notes
          notebookTitle: "New Note",
          notebookColor: Colors.grey.shade300, initialText: '',
        ),
      ),
    );
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
          // Chipmunk greeting
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
                const Expanded(
                  child: Text(
                    "Hi adventurer! Ready to jot down your thoughts today?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                )
              ],
            ),
          ),

          // Notebook carousel
          SizedBox(
            height: 160,
            child: _notebooks.isEmpty
                ? const Center(child: Text("No notebooks yet. Tap + to add one!"))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _notebooks.length,
                    itemBuilder: (_, index) {
                      final nb = _notebooks[index];
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

          // Buttons
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEntryScreen(
          notebookId: widget.notebook['id'],
          notebookTitle: widget.notebook['title'],
          notebookColor: Color(widget.notebook['color']), initialText: '',
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
                final dateStr = note['createdAt'] ?? note['timestamp'] ?? '';
                final date = dateStr.isNotEmpty
                    ? DateTime.tryParse(dateStr)
                    : null;
                return ListTile(
                  title: Text(
                    note['content'].split('\n').first,
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
