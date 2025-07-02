import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

Future<String> scanNoteFromImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);

  if (pickedFile == null) return '';

  final inputImage = InputImage.fromFile(File(pickedFile.path));
  final textRecognizer = TextRecognizer();

  final recognizedText = await textRecognizer.processImage(inputImage);
  await textRecognizer.close();

  return recognizedText.text;
}
