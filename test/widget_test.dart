import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dailyquest/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // 🛠️ Provide required argument isLoggedIn: false
    await tester.pumpWidget(const DailyQuestApp());

    // This test assumes there's a counter UI, but your app doesn't use one.
    // So this part likely needs to be removed or replaced.

    // Example fallback to check if login screen shows
    expect(find.text('Welcome back!'), findsOneWidget); // Adjust to match actual login text

    // OR: test login form fields
    expect(find.byType(TextField), findsNWidgets(2)); // Email and password
  });
}
