import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

/// ✅ List of 31 daily quotes to show each day of the month
final List<String> dailyQuotes = [
  "Start small, dream big.",
  "Progress is progress, no matter how small.",
  "You are capable of amazing things.",
  "Don’t wait for opportunity. Create it.",
  "Believe you can and you’re halfway there.",
  "Small steps every day lead to big changes.",
  "Be patient. Good things take time.",
  "Mistakes are proof that you are trying.",
  "Your only limit is your mind.",
  "Push yourself, because no one else is going to do it for you.",
  "Focus on your journey, not their path.",
  "Dream it. Wish it. Do it.",
  "Every day is a second chance.",
  "Act as if what you do makes a difference. It does.",
  "Stay positive, work hard, make it happen.",
  "Don’t quit. Suffer now and live the rest of your life as a champion.",
  "It’s going to be hard, but hard does not mean impossible.",
  "Discipline is choosing between what you want now and what you want most.",
  "You don’t have to be perfect to be amazing.",
  "Keep going. You’re closer than you think.",
  "The secret to getting ahead is getting started.",
  "Doubt kills more dreams than failure ever will.",
  "Hustle in silence. Let your success make the noise.",
  "You’ve got this.",
  "Nothing changes if nothing changes.",
  "Your future depends on what you do today.",
  "Growth is growth, no matter how small.",
  "Great things never come from comfort zones.",
  "Be stronger than your excuses.",
  "Focus on the step in front of you, not the whole staircase."
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// ✅ Get current logged-in Firebase user
    final user = FirebaseAuth.instance.currentUser;

    /// ✅ Open Hive box to retrieve user XP and streak data
    final userBox = Hive.box('userData');
    final int xp = userBox.get('xp', defaultValue: 0);
    final int streak = userBox.get('streak', defaultValue: 0);

    /// ✅ Calculate which quote to show today
    int dayOfMonth = DateTime.now().day;
    String todayQuote =
        dailyQuotes[(dayOfMonth - 1) % dailyQuotes.length];

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
            // 👋 Greeting row with profile picture and name
            Row(
              children: [
                /// ✅ Show Google profile picture if available
                CircleAvatar(
                  radius: 35,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  backgroundColor: Colors.brown.shade200,
                  child: user?.photoURL == null
                      ? const Icon(
                          Icons.person,
                          size: 35,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                /// ✅ Greeting text
                Expanded(
                  child: Text(
                    'Hi, ${user?.displayName ?? 'User'} 👋',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// 📈 Card showing XP and Streak
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              color: Colors.brown[100],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      icon: Icons.star,
                      label: 'XP',
                      value: '$xp',
                    ),
                    _StatItem(
                      icon: Icons.local_fire_department,
                      label: 'Streak',
                      value: '$streak Days',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            /// ⚡ Quick Actions Grid
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

            const SizedBox(height: 12),

            /// ✅ Daily motivational quote
            Center(
              child: Text(
                '“$todayQuote”',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Helper method to generate Quick Action tiles
  Widget _quickTile(
      BuildContext context, IconData icon, String label, String route) {
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

/// ✅ Widget to show XP and Streak stats
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
