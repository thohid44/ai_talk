import 'package:ai_talk_test/core/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AI Talk',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0E2A47),
              brightness: Brightness.light,
            ).copyWith(
              primary: const Color(0xFF0E2A47),
              onPrimary: Colors.white,
              surface: Colors.white,
              error: const Color(0xFFC0392B),
            ),
            scaffoldBackgroundColor: const Color(0xFFF4F6F8),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0E2A47),
              foregroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              surfaceTintColor: Colors.transparent,
            ),
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}

