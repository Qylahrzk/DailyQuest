import 'package:flutter/material.dart';

class AppLoadingPage extends StatelessWidget {
  const AppLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50, // Optional background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator.adaptive(),
            SizedBox(height: 16),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
