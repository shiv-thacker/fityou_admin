import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'features/login/presentation/screens/auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FashionAdminApp());
}

class FashionAdminApp extends StatelessWidget {
  const FashionAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fashion Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}
