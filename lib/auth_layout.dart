import 'package:dailyquest/app_loading_page.dart';
import 'package:dailyquest/auth/get_started_screen.dart';
import 'package:dailyquest/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_navigation_layout.dart'; // ✅ make sure this is a Widget

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, this.pageIfNotConnected});

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingPage();
        } else if (snapshot.hasData) {
          return const AppNavigationLayout();
        } else {
          return pageIfNotConnected ?? const GetStartedScreen();
        }
      },
    );
  }
}