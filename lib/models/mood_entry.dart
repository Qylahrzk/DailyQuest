import 'package:hive/hive.dart';

part 'mood_entry.g.dart'; // required for Hive type adapter generation

@HiveType(typeId: 0)
class MoodEntry extends HiveObject {
  @HiveField(0)
  String mood; // e.g. "Happy", "Sad", "Excited"

  @HiveField(1)
  String note; // user's diary or journal note

  @HiveField(2)
  DateTime timestamp; // when the entry was created or updated

  MoodEntry({
    required this.mood,
    required this.note,
    required this.timestamp,
  });

  /// ✅ Common mood suggestions you might show to users
  static const List<String> commonMoods = [
    'Happy',
    'Sad',
    'Angry',
    'Excited',
    'Anxious',
    'Calm',
    'Bored',
    'Motivated',
    'Tired',
    'Stressed',
    'Relaxed',
    'Confident',
    'Lonely',
    'Grateful',
    'Hopeful',
    'Frustrated',
    'Overwhelmed',
    'Content',
    'Proud',
    'Worried',
  ];
}
