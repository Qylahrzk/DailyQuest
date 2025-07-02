// lib/models/todo.dart

class Todo {
  int? id;
  String title;
  String description;
  String priority; // 'high', 'medium', 'low'
  String status;   // 'completed', 'ongoing', etc.
  String date;     // yyyy-MM-dd
  String time;     // HH:mm
  String createdAt;

  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.date,
    required this.time,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'date': date,
      'time': time,
      'createdAt': createdAt,
    };
  }

  static Todo fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      priority: map['priority'],
      status: map['status'],
      date: map['date'],
      time: map['time'],
      createdAt: map['createdAt'],
    );
  }
}
