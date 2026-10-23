import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../features/login/data/datasources/auth_datasource.dart';
import '../../../../features/login/data/repositories/auth_repository_impl.dart';
import '../../../../features/creators/presentation/screens/creators_screen.dart';
import '../../../../features/outfits/presentation/screens/outfits_screen.dart';
import '../widgets/sidebar_widget.dart';

/// Root shell: sidebar navigation + IndexedStack of feature screens.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  static const _screens = [
    CreatorsScreen(),
    OutfitsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _debugSession();
  }

  Future<void> _debugSession() async {
    if (!kDebugMode) return;
    final repo = AuthRepositoryImpl(AuthDatasource());
    final user = repo.currentUser;
    if (user == null) return;
    final isAdmin = await repo.isCurrentUserAdmin;
    debugPrint(
        'Session: uid=${user.uid}, isAdmin=$isAdmin '
        '(users/${user.uid}.isAdmin)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Row(
        children: [
          SidebarWidget(
            selectedIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
          const VerticalDivider(width: 1, color: Colors.white12),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}
