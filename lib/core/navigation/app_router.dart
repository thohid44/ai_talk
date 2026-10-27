import 'package:ai_talk_test/features/auth/presentation/screens/login_screen.dart';
import 'package:ai_talk_test/features/home/presentation/screens/home_screen.dart';
import 'package:ai_talk_test/features/profile/presentation/screens/profile_screen.dart';
import 'package:ai_talk_test/features/promo/presentation/screens/promo_materials_screen.dart';
import 'package:ai_talk_test/features/signals/presentation/screens/signals_archive_screen.dart';
import 'package:ai_talk_test/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String signals = '/signals';
  static const String promo = '/promo';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(settings, const SplashScreen());
      case AppRoutes.login:
        return _page(settings, const LoginScreen());
      case AppRoutes.home:
        return _page(settings, const HomeScreen());
      case AppRoutes.profile:
        return _page(settings, const ProfileScreen());
      case AppRoutes.signals:
        return _page(settings, const SignalsArchiveScreen());
      case AppRoutes.promo:
        return _page(settings, const PromoMaterialsScreen());
      default:
        return _page(
          settings,
          const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }

  static MaterialPageRoute<dynamic> _page(
    RouteSettings settings,
    Widget child,
  ) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) => child,
    );
  }
}
