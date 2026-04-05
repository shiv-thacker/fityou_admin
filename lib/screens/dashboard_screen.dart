import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';
import 'creators_screen.dart';
import 'outfits_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _logSessionDebug();
  }

  Future<void> _logSessionDebug() async {
    if (!kDebugMode) return;
    final auth = AuthService();
    final user = auth.currentUser;
    if (user == null) return;
    final isAdmin = await auth.isCurrentUserAdmin;
    debugPrint(
      'Session: user.uid=${user.uid}, isAdmin=$isAdmin '
      '(Firestore users/${user.uid}.isAdmin)',
    );
  }

  static const _screens = [
    CreatorsScreen(),
    OutfitsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
          const VerticalDivider(width: 1, color: Colors.white12),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
