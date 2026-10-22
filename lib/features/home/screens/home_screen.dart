import 'package:ai_talk_test/core/navigation/app_router.dart';
import 'package:ai_talk_test/features/profile/screens/profile_screen.dart';
import 'package:ai_talk_test/features/promo/screens/promo_materials_screen.dart';
import 'package:ai_talk_test/features/signals/screens/signals_archive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.accountId});

  final String? accountId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Do you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final displayId = widget.accountId?.trim();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            accountId: displayId,
            onLogout: _confirmLogout,
          ),
          ProfileScreen(accountId: displayId),
          const SignalsArchiveScreen(),
          const PromoMaterialsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF8A97A6),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.candlestick_chart_outlined),
            activeIcon: Icon(Icons.candlestick_chart),
            label: 'Signals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Promo',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.accountId, required this.onLogout});

  final String? accountId;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final displayId = accountId?.trim();
    final hasAccountId = displayId != null && displayId.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Talk'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFE3E8EF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2332),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Login ID',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5C6B7A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    hasAccountId ? displayId : 'Not available',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: hasAccountId ? const Color(0xFF1A2332) : const Color(0xFF8A97A6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
