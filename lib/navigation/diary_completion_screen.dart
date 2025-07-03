import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class DiaryCompletionScreen extends StatefulWidget {
  final int totalEntries;
  final int currentDay;

  const DiaryCompletionScreen({
    super.key,
    required this.totalEntries,
    required this.currentDay,
  });

  @override
  State<DiaryCompletionScreen> createState() => _DiaryCompletionScreenState();
}

class _DiaryCompletionScreenState extends State<DiaryCompletionScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF2DC),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🎉 Confetti widget
                  SizedBox(
                    height: 100,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      emissionFrequency: 0.05,
                      numberOfParticles: 20,
                      colors: const [
                        Colors.orange,
                        Colors.brown,
                        Colors.amber,
                        Colors.yellow,
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 🏆 Trophy image
                  Image.asset(
                    'assets/images/trophy.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 24),

                  // ✅ Progress
                  Text(
                    "${widget.totalEntries}/${widget.totalEntries} completed",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🎯 Motivational text
                  Text(
                    "You've completed your Day ${widget.currentDay} diary.\nToday is your day. Let's level up!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      "Go to Mood & Diary",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
