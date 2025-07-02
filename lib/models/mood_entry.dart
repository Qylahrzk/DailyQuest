import 'package:intl/intl.dart';

class MoodEntry {
  int? id;
  String mood;
  String note;
  DateTime timestamp;

  MoodEntry({
    this.id,
    required this.mood,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'mood': mood,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'] as int?,
      mood: map['mood'] as String? ?? '',
      note: map['note'] as String? ?? '',
      timestamp: DateTime.parse(
        map['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  String get formattedDate {
    return DateFormat.yMMMEd().add_jm().format(timestamp);
  }

  MoodEntry copyWith({
    int? id,
    String? mood,
    String? note,
    DateTime? timestamp,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

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
