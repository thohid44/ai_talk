import 'package:ai_talk_test/core/navigation/app_router.dart';
import 'package:ai_talk_test/core/theme/app_colors.dart';
import 'package:ai_talk_test/core/widgets/responsive_frame.dart';
import 'package:ai_talk_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:ai_talk_test/features/profile/presentation/providers/profile_provider.dart';
import 'package:ai_talk_test/features/profile/presentation/screens/profile_screen.dart';
import 'package:ai_talk_test/features/promo/presentation/providers/promo_provider.dart';
import 'package:ai_talk_test/features/promo/presentation/screens/promo_materials_screen.dart';
import 'package:ai_talk_test/features/signals/presentation/providers/signals_provider.dart';
import 'package:ai_talk_test/features/signals/presentation/screens/signals_archive_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

    final auth = context.read<AuthProvider>();
    context.read<ProfileProvider>().clear();
    context.read<SignalsProvider>().clear();
    context.read<PromoProvider>().clear();
    await auth.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayId = context.watch<AuthProvider>().session?.login.toString();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(
            accountId: displayId,
            onLogout: _confirmLogout,
            onOpenTab: (index) => setState(() => _currentIndex = index),
          ),
          const ProfileScreen(),
          const SignalsArchiveScreen(),
          const PromoMaterialsScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.candlestick_chart_outlined),
              selectedIcon: Icon(Icons.candlestick_chart),
              label: 'Signals',
            ),
            NavigationDestination(
              icon: Icon(Icons.campaign_outlined),
              selectedIcon: Icon(Icons.campaign),
              label: 'Promo',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.accountId,
    required this.onLogout,
    required this.onOpenTab,
  });

  final String? accountId;
  final VoidCallback onLogout;
  final ValueChanged<int> onOpenTab;

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
        top: false,
        bottom: false,
        child: ResponsiveFrame(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Login ID',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      hasAccountId ? displayId : 'Not available',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 22.h),
              Text(
                'Quick access',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 10.h),
              _Shortcut(
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'Account details and balances',
                onTap: () => onOpenTab(1),
              ),
              SizedBox(height: 10.h),
              _Shortcut(
                icon: Icons.candlestick_chart_outlined,
                title: 'Signals',
                subtitle: 'Archive by pair and date',
                onTap: () => onOpenTab(2),
              ),
              SizedBox(height: 10.h),
              _Shortcut(
                icon: Icons.campaign_outlined,
                title: 'Promo',
                subtitle: 'Current promotional materials',
                onTap: () => onOpenTab(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(color: AppColors.line),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  height: 40.w,
                  width: 40.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: AppColors.navy, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.hint, size: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
