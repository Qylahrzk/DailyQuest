import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:zefyrka/zefyrka.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/note_dao.dart';
import '../notes/achievement_service.dart';

class NoteEntryScreen extends StatefulWidget {
  final int notebookId;
  final String notebookTitle;
  final Color notebookColor;
  final String? initialText;

  const NoteEntryScreen({
    super.key,
    required this.notebookId,
    required this.notebookTitle,
    required this.notebookColor,
    this.initialText,
  });

  @override
  State<NoteEntryScreen> createState() => _NoteEntryScreenState();
}

class _NoteEntryScreenState extends State<NoteEntryScreen> {
  late ZefyrController _zefyrController;
  final FocusNode _focusNode = FocusNode();

  File? _attachedImage;
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();

    NotusDocument doc;
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      try {
        final decoded = jsonDecode(widget.initialText!);
        doc = NotusDocument.fromJson(decoded);
      } catch (_) {
        doc = NotusDocument()..insert(0, widget.initialText!);
      }
    } else {
      doc = NotusDocument();
    }

    _zefyrController = ZefyrController(doc);
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final data = await NoteDao.getNotesByNotebook(widget.notebookId);
    if (!mounted) return;
    setState(() => _notes = data);
  }

  Future<void> _saveNote() async {
    final jsonContent = jsonEncode(_zefyrController.document.toJson());

    if (_zefyrController.document.length == 0 && _attachedImage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note is empty!")),
      );
      return;
    }

    await NoteDao.insertNote(
      widget.notebookId,
      jsonContent,
      DateTime.now().toIso8601String(),
    );

    AchievementService.addXp(10);
    AchievementService.checkAchievements();

    setState(() {
      _zefyrController = ZefyrController(NotusDocument());
      _attachedImage = null;
    });

    await _loadNotes();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Note saved successfully!")),
    );
  }

  Future<void> _deleteNote(int id) async {
    await NoteDao.deleteNote(id);
    AchievementService.addXp(5);
    await _loadNotes();
  }

  Future<void> _exportPdf(String jsonContent) async {
    final plain = _extractPlainText(jsonContent);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Text(plain, style: pw.TextStyle(fontSize: 16)),
        ),
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "note.pdf",
    );
  }

  String _extractPlainText(String jsonContent) {
    try {
      final doc = NotusDocument.fromJson(jsonDecode(jsonContent));
      return doc.toPlainText().trim();
    } catch (_) {
      return jsonContent;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _attachedImage = File(file.path));
    }
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ZefyrToolbar.basic(controller: _zefyrController),
          ),
          Expanded(
            child: Container(
              color: widget.notebookColor.withAlpha((0.15 * 255).toInt()),
              child: ZefyrEditor(
                controller: _zefyrController,
                focusNode: _focusNode,
                autofocus: false,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          if (_attachedImage != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Image.file(_attachedImage!, height: 120),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                ElevatedButton(
                  onPressed: _saveNote,
                  child: const Text("Save Note"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _notes.isEmpty
                ? const Center(child: Text("No notes yet."))
                : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      final createdAt = DateTime.tryParse(note['createdAt']);
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                            _extractPlainText(note['content']),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: createdAt != null
                              ? Text(
                                  DateFormat.yMMMEd().add_jm().format(createdAt),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf),
                                onPressed: () => _exportPdf(note['content']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteNote(note['id']),
                              ),
                            ],
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
