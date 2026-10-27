import 'package:ai_talk_test/core/navigation/app_router.dart';
import 'package:ai_talk_test/core/theme/app_colors.dart';
import 'package:ai_talk_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openNext();
    });
  }

  Future<void> _openNext() async {
    await Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 800)),
      _restoreSession(),
    ]);
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    Navigator.pushReplacementNamed(
      context,
      auth.isLoggedIn ? AppRoutes.home : AppRoutes.login,
    );
  }

  Future<void> _restoreSession() async {
    try {
      await GetStorage.init().timeout(const Duration(seconds: 2));
    } catch (_) {}
    if (!mounted) return;
    context.read<AuthProvider>().restore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 72.w,
                width: 72.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Icon(Icons.show_chart, color: Colors.white, size: 36.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                'AiTalk Peanut',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: 28.w,
                height: 28.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
