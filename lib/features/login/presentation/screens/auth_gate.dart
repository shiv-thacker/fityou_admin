import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../main_shell/presentation/screens/main_shell_screen.dart';
import 'login_screen.dart';

/// Root router: watches Firebase auth state and shows either the
/// [MainShellScreen] (logged-in admin) or the [LoginScreen].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.primary,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const MainShellScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
