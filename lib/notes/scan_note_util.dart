import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:zefyrka/zefyrka.dart';

/// Scans text from an image from camera or gallery.
///
/// Returns the recognized text **as Zefyr JSON** string.
///
/// Example JSON output:
/// ```json
/// [
///   { "insert": "Hello scanned note\n" }
/// ]
/// ```
Future<String> scanNoteFromImage({ImageSource source = ImageSource.camera}) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);
  if (pickedFile == null) return '';

  final inputImage = InputImage.fromFile(File(pickedFile.path));
  final textRecognizer = TextRecognizer();

  final recognizedText = await textRecognizer.processImage(inputImage);
  await textRecognizer.close();

  final text = recognizedText.text.trim();

  if (text.isEmpty) return '';

  // ✅ Wrap scanned text as a Zefyr NotusDocument
  final doc = NotusDocument()..insert(0, text);
  return jsonEncode(doc.toJson());
}
