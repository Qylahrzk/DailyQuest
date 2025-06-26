import 'package:flutter/material.dart';
import 'package:dailyquest/home/home_screen.dart';
// TODO: Import your other screens here
// import 'package:dailyquest/screens/mood/mood_screen.dart';
// import 'package:dailyquest/screens/notes/notes_screen.dart';
// import 'package:dailyquest/screens/todo/todo_screen.dart';
// import 'package:dailyquest/screens/profile/profile_screen.dart';

class AppNavigationLayout extends StatefulWidget {
  const AppNavigationLayout({super.key});

  @override
  State<AppNavigationLayout> createState() => _AppNavigationLayoutState();
}

class _AppNavigationLayoutState extends State<AppNavigationLayout> {
  int _currentIndex = 0;

  // Replace with your actual screens
  final List<Widget> _screens = const [
    HomeScreen(),
    Placeholder(child: Center(child: Text('Mood Diary'))),
    Placeholder(child: Center(child: Text('Notes'))),
    Placeholder(child: Center(child: Text('To-Do'))),
    Placeholder(child: Center(child: Text('Profile'))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.mood), label: 'Diary'),
          BottomNavigationBarItem(icon: Icon(Icons.notes), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'To-Do'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
