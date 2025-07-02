import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/note_dao.dart';

class NoteEntryScreen extends StatefulWidget {
  final int notebookId;
  final String notebookTitle;
  final Color notebookColor;

  const NoteEntryScreen({
    super.key,
    required this.notebookId,
    required this.notebookTitle,
    required this.notebookColor, required String initialText,
  });

  @override
  State<NoteEntryScreen> createState() => _NoteEntryScreenState();
}

class _NoteEntryScreenState extends State<NoteEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  /// 🟢 Load all notes from this notebook
  Future<void> _loadNotes() async {
    final data = await NoteDao.getNotesByNotebook(widget.notebookId);
    setState(() {
      _notes = data;
    });
  }

  /// 🟢 Save a new note to this notebook
  Future<void> _saveNote() async {
    if (_controller.text.trim().isEmpty) return;

    await NoteDao.insertNote(
      widget.notebookId,
      _controller.text.trim(),
      DateTime.now().toIso8601String(),
    );

    _controller.clear();
    _loadNotes();
  }

  /// 📄 Export this note as PDF
  Future<void> _exportPdf(String noteText) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Text(
            noteText,
            style: pw.TextStyle(fontSize: 16),
          ),
        ),
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'note.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.notebookTitle),
        backgroundColor: widget.notebookColor,
      ),
      body: Column(
        children: [
          // 📝 Note input field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Write your note...",
                filled: true,
                // ignore: deprecated_member_use
                fillColor: widget.notebookColor.withOpacity(0.15),
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // 💾 Save note button
          ElevatedButton(
            onPressed: _saveNote,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.notebookColor,
            ),
            child: const Text("Save Note"),
          ),

          const SizedBox(height: 20),

          // 📚 List of existing notes
          Expanded(
            child: _notes.isEmpty
                ? const Center(child: Text("No notes yet."))
                : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      final createdAt = DateTime.parse(note['createdAt']);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(note['content']),
                          subtitle: Text(DateFormat.yMMMEd().add_jm().format(createdAt)),
                          trailing: IconButton(
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                            onPressed: () => _exportPdf(note['content']),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
