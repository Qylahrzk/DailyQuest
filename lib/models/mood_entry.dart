import 'package:hive/hive.dart';

part 'mood_entry.g.dart'; // Needed for codegen

@HiveType(typeId: 0)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final String mood;

  @HiveField(1)
  final String note;

  @HiveField(2)
  final DateTime timestamp;

  MoodEntry({required this.mood, required this.note, required this.timestamp});
}
