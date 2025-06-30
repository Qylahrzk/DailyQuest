import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dailyquest/app_loading_page.dart';
import 'package:dailyquest/auth/get_started_screen.dart';
import 'package:dailyquest/auth_service.dart';
import 'package:dailyquest/app_navigation_layout.dart';

// ✅ Create a global instance of AuthService
final authService = AuthService();

/// This widget listens to the authentication state
/// and routes the user accordingly.
///
/// - If still waiting → shows loading page
/// - If logged in → shows AppNavigationLayout
/// - If not logged in → shows GetStartedScreen
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  /// Optional widget to show instead of GetStartedScreen
  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges, // ✅ uses global instance
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // ⏳ Show loading while waiting for Firebase
          return const AppLoadingPage();
        } else if (snapshot.hasData) {
          // ✅ User is logged in
          return const AppNavigationLayout();
        } else {
          // 🔒 User not logged in
          return pageIfNotConnected ?? const GetStartedScreen();
        }
      },
    );
  }
}
