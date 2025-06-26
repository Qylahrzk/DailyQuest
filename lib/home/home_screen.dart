import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart'; // ✅ Import Hive to get XP and streak

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get current user from Firebase
    final user = FirebaseAuth.instance.currentUser;

    // ✅ Get XP and Streak values from Hive
    final userBox = Hive.box('userData');
    final int xp = userBox.get('xp', defaultValue: 0);
    final int streak = userBox.get('streak', defaultValue: 0);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'DailyQuest',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👋 Greeting with Avatar
            Row(
              children: [
                // 👤 Profile Picture
                CircleAvatar(
                  radius: 35,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  backgroundColor: Colors.brown.shade200,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, size: 35, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                // 🧑 Welcome Text
                Expanded(
                  child: Text(
                    'Hi, ${user?.displayName ?? 'User'} 👋',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 📈 Stats Card (XP & Streak)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              color: Colors.brown[100],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(icon: Icons.star, label: 'XP', value: '$xp'),
                    _StatItem(
                        icon: Icons.local_fire_department,
                        label: 'Streak',
                        value: '$streak Days'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ⚡ Quick Actions Section Title
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // ⚡ Quick Actions Grid (Mood, Notes, To-Do, Profile)
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _quickTile(context, Icons.mood, 'Mood', '/mood'),
                  _quickTile(context, Icons.notes, 'Notes', '/notes'),
                  _quickTile(context, Icons.check_circle, 'To-Do', '/todo'),
                  _quickTile(context, Icons.person, 'Profile', '/profile'),
                ],
              ),
            ),

            // 💡 Motivational Quote (you can randomize this later)
            const SizedBox(height: 12),
            const Center(
              child: Text(
                '“Small steps every day lead to big changes.”',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📦 Widget for each Quick Action Button
  Widget _quickTile(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.brown[200],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.shade100,
              offset: const Offset(2, 4),
              blurRadius: 6,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 📊 Widget for Stat Item (XP & Streak)
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 28, color: Colors.brown[800]),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}