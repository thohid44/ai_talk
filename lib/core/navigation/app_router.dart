import 'package:ai_talk_test/features/auth/screens/login_screen.dart';
import 'package:ai_talk_test/features/home/screens/home_screen.dart';
import 'package:ai_talk_test/features/profile/screens/profile_screen.dart';
import 'package:ai_talk_test/features/promo/screens/promo_materials_screen.dart';
import 'package:ai_talk_test/features/signals/screens/signals_archive_screen.dart';
import 'package:ai_talk_test/splash_screen.dart';
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
        return _page(settings, HomeScreen(accountId: _accountId(settings.arguments)));
      case AppRoutes.profile:
        return _page(settings, ProfileScreen(accountId: _accountId(settings.arguments)));
      case AppRoutes.signals:
        return _page(settings, const SignalsArchiveScreen());
      case AppRoutes.promo:
        return _page(settings, const PromoMaterialsScreen());
      default:
        return _page(
          settings,
          const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }

  static String? _accountId(Object? arguments) {
    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments.trim();
    }
    return null;
  }

  static MaterialPageRoute<dynamic> _page(RouteSettings settings, Widget child) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) => child,
    );
  }
}
