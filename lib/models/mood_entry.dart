/// ✅ MoodEntry Model
/// Represents a single mood diary entry
class MoodEntry {
  int? id;               // Auto-increment ID from the database
  String mood;           // Mood label (e.g., "Happy", "Sad")
  String emoji;          // Emoji icon related to the mood
  String note;           // User-written diary entry
  DateTime timestamp;    // Timestamp when the entry was saved
  int wordCount;         // Auto-calculated word count of the note

  MoodEntry({
    this.id,
    required this.mood,
    required this.emoji,
    required this.note,
    required this.timestamp,
    required this.wordCount,
  });

  /// 🔁 Convert MoodEntry to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mood': mood,
      'emoji': emoji,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'wordCount': wordCount,
    };
  }

  /// 🔁 Convert Map from SQLite into MoodEntry object
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    return MoodEntry(
      id: map['id'],
      mood: map['mood'],
      emoji: map['emoji'],
      note: map['note'],
      timestamp: DateTime.parse(map['timestamp']),
      wordCount: map['wordCount'] ?? 0,
    );
  }

  /// ✅ Create a copy with new values
  MoodEntry copyWith({
    String? mood,
    String? emoji,
    String? note,
    DateTime? timestamp,
    int? wordCount,
  }) {
    return MoodEntry(
      id: id,
      mood: mood ?? this.mood,
      emoji: emoji ?? this.emoji,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      wordCount: wordCount ?? this.wordCount,
    );
  }
}
