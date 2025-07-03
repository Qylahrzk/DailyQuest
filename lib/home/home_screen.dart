import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:lottie/lottie.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../diary/mood_diary_screen.dart';
import '../todo/todo_screen.dart';
import '../notes/notes_screen.dart';
import '../settings/settings_screen.dart';

/// ------------------------------
/// Daily Motivational Quotes
/// ------------------------------
final List<String> dailyQuotes = [
  "Start small, dream big.",
  "Progress is progress, no matter how small.",
  "You are capable of amazing things.",
  "Don’t wait for opportunity. Create it.",
  "Stay consistent, even on tough days.",
  "Make yourself proud today.",
  "The smallest step still moves you forward.",
  "Keep writing your story.",
  "You’ve overcome so much already.",
  "Focus on today’s page, not the whole book.",
  "Your journey matters.",
  "Celebrate your small wins.",
  "Your thoughts shape your reality.",
  "Creativity comes when you show up.",
  "Keep going, you’re closer than you think.",
  "Breathe. Reset. Restart.",
  "You are writing your legacy.",
  "Your words have power.",
  "Progress > perfection.",
  "New day, new energy.",
  "Create the life you imagine.",
  "Don’t stop believing in yourself.",
  "Your effort matters.",
  "Your feelings are valid.",
  "Turn struggles into stories.",
  "Your dreams are worth it.",
  "Embrace your journey.",
  "Shine your own light.",
  "One page at a time.",
  "Keep moving forward."
];

/// ------------------------------
/// HomeScreen Widget
/// ------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _homeData;

  @override
  void initState() {
    super.initState();
    _homeData = _loadHomeData();
  }

  /// Load all data for Home screen
  Future<Map<String, dynamic>> _loadHomeData() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dailyquest.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            xp INTEGER,
            streak INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            priority INTEGER,
            isDone INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS moods (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mood TEXT,
            note TEXT,
            timestamp TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS notebooks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS notifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            body TEXT,
            timestamp TEXT
          )
        ''');
      },
    );

    int xp = 0;
    int streak = 0;
    List<Map<String, dynamic>> todos = [];
    List<Map<String, dynamic>> diaries = [];
    List<Map<String, dynamic>> notebooks = [];
    List<Map<String, dynamic>> notifications = [];

    try {
      final userRows = await db.query('users', limit: 1);
      if (userRows.isNotEmpty) {
        xp = (userRows[0]['xp'] as int?) ?? 0;
        streak = (userRows[0]['streak'] as int?) ?? 0;
      }
    } catch (_) {}

    try {
      todos = await db.query('todos', orderBy: 'priority DESC', limit: 3);
    } catch (_) {}

    try {
      diaries = await db.query('moods', orderBy: 'timestamp DESC', limit: 3);
    } catch (_) {}

    try {
      notebooks = await db.query('notebooks', orderBy: 'id DESC', limit: 10);
    } catch (_) {}

    try {
      notifications = await db.query(
        'notifications',
        orderBy: 'timestamp DESC',
        limit: 10,
      );
    } catch (_) {}

    final location = await _getCurrentLocation();

    return {
      'xp': xp,
      'streak': streak,
      'todos': todos,
      'diaries': diaries,
      'notebooks': notebooks,
      'notifications': notifications,
      'location': location,
    };
  }

  /// Retrieves current location with permission
  Future<String> _getCurrentLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return "Location Disabled";

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return "Permission Denied";
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return "Permission Denied Forever";
      }

      Position pos = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return "${p.locality ?? 'Unknown'}, ${p.country ?? ''}";
      }
      return "Unknown Location";
    } catch (_) {
      return "Location Error";
    }
  }

  void _showNotifications(BuildContext context, List<Map<String, dynamic>> notifications) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notifications"),
        content: notifications.isEmpty
            ? const Text("No notifications found.")
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (_, i) {
                    final notif = notifications[i];
                    return ListTile(
                      title: Text(notif["title"] ?? ""),
                      subtitle: Text(notif["body"] ?? ""),
                      trailing: Text(
                        notif["timestamp"] ?? "",
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  /// Adds a sample notification
  Future<void> _addSampleNotification() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dailyquest.db');
    final db = await openDatabase(path);
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await db.insert("notifications", {
      "title": "New Achievement!",
      "body": "You've unlocked a new badge.",
      "timestamp": now,
    });

    setState(() {
      _homeData = _loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final day = DateTime.now().day;
    final quote = dailyQuotes[(day - 1) % dailyQuotes.length];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2E3),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleNotification,
        backgroundColor: const Color(0xFFA15822),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _homeData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("No data found."));
            }

            final data = snapshot.data!;
            final xp = data['xp'] as int;
            final streak = data['streak'] as int;
            final location = data['location'] as String;
            final todos = data['todos'] as List<Map<String, dynamic>>;
            final diaries = data['diaries'] as List<Map<String, dynamic>>;
            final notebooks = data['notebooks'] as List<Map<String, dynamic>>;
            final notifications =
                data['notifications'] as List<Map<String, dynamic>>;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTopBar(context, notifications),
                const SizedBox(height: 12),
                _buildWelcomeCard(
                  user?.displayName ?? "Adventurer",
                  location,
                  quote,
                ),
                const SizedBox(height: 20),
                GamifiedUserStatsCard(xp: xp, streak: streak),
                const SizedBox(height: 20),
                SectionTitle(
                  title: "Your To-Do List",
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TodoScreen()),
                    );
                  },
                ),
                ...todos.map((t) => ToDoItemTile(todo: t)),
                const SizedBox(height: 20),
                SectionTitle(
                  title: "Recent Diary Entries",
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MoodDiaryScreen()),
                    );
                  },
                ),
                ...diaries.map((d) => DiaryItemTile(diary: d)),
                const SizedBox(height: 20),
                SectionTitle(
                  title: "Your Notebooks",
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotesScreen()),
                    );
                  },
                ),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: notebooks.length,
                    itemBuilder: (_, i) =>
                        NotebookCard(notebook: notebooks[i]),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, List<Map<String, dynamic>> notifications) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "DailyQuest.",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A2B14),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black87),
              onPressed: () => _showNotifications(context, notifications),
            ),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(String username, String location, String quote) {
    final now = DateTime.now();
    
    final formattedDate = DateFormat('dd MMMM ').format(now).toUpperCase();
    final formattedDayShort = DateFormat('EEE').format(now).toUpperCase();

    final displayDate = "$formattedDate | $formattedDayShort";
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFCF722C), Color(0xFFFAD8A5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: "Welcome Back - Adventurer! ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Color(0xFF4A2B14),
                    ),
                    children: [
                      TextSpan(
                        text: username,
                        style: const TextStyle(
                          color: Color(0xFFA15822),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayDate,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "“$quote”",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(),
                  Text(
                    "_____________________________",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Lottie.asset(
                'assets/animations/ChipiJump.json',
                width: 200,
                height: 200,
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      );
    }
  }

/// ------------------------------
/// GamifiedUserStatsCard Widget
/// ------------------------------
class GamifiedUserStatsCard extends StatelessWidget {
  final int xp;
  final int streak;

  const GamifiedUserStatsCard({
    super.key,
    required this.xp,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEEBC8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 4),
            blurRadius: 6,
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.stars, size: 40, color: Color(0xFFA15822)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("XP: $xp",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF4A2B14))),
                Text("Streak: $streak days",
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF4A2B14))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------
/// SectionTitle Widget
/// ------------------------------
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const SectionTitle({
    super.key,
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A2B14)),
        ),
        const Spacer(),
        TextButton(
          onPressed: onViewAll,
          child: const Text(
            "View All",
            style: TextStyle(color: Color(0xFFA15822)),
          ),
        ),
      ],
    );
  }
}

/// ------------------------------
/// ToDoItemTile Widget
/// ------------------------------
class ToDoItemTile extends StatelessWidget {
  final Map<String, dynamic> todo;

  const ToDoItemTile({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        todo["isDone"] == 1
            ? Icons.check_circle
            : Icons.radio_button_unchecked,
        color: todo["priority"] == 3
            ? Colors.red
            : (todo["priority"] == 2 ? Colors.orange : Colors.green),
      ),
      title: Text(todo["title"] ?? ""),
      trailing: Text(
        todo["priority"] == 3
            ? "High"
            : (todo["priority"] == 2 ? "Medium" : "Low"),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// ------------------------------
/// DiaryItemTile Widget
/// ------------------------------
class DiaryItemTile extends StatelessWidget {
  final Map<String, dynamic> diary;

  const DiaryItemTile({
    super.key,
    required this.diary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.mood, color: Color(0xFFA15822)),
      title: Text(diary["mood"] ?? ""),
      subtitle: Text(diary["note"] ?? ""),
      trailing: Text(
        diary["timestamp"] ?? "",
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

/// ------------------------------
/// NotebookCard Widget
/// ------------------------------
class NotebookCard extends StatelessWidget {
  final Map<String, dynamic> notebook;

  const NotebookCard({
    super.key,
    required this.notebook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFCF722C), Color(0xFFFAD8A5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notebook["title"] ?? "Untitled",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notebook["description"] ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
