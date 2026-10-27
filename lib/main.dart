import 'package:ai_talk_test/core/navigation/app_router.dart';
import 'package:ai_talk_test/core/network/http_api.dart';
import 'package:ai_talk_test/core/theme/app_colors.dart';
import 'package:ai_talk_test/core/theme/app_theme.dart';
import 'package:ai_talk_test/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ai_talk_test/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ai_talk_test/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ai_talk_test/features/auth/domain/usecases/login_user.dart';
import 'package:ai_talk_test/features/auth/domain/usecases/logout_user.dart';
import 'package:ai_talk_test/features/auth/domain/usecases/restore_session.dart';
import 'package:ai_talk_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:ai_talk_test/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ai_talk_test/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ai_talk_test/features/profile/domain/usecases/load_profile.dart';
import 'package:ai_talk_test/features/profile/presentation/providers/profile_provider.dart';
import 'package:ai_talk_test/features/promo/data/datasources/promo_remote_data_source.dart';
import 'package:ai_talk_test/features/promo/data/repositories/promo_repository_impl.dart';
import 'package:ai_talk_test/features/promo/domain/usecases/load_promo_materials.dart';
import 'package:ai_talk_test/features/promo/presentation/providers/promo_provider.dart';
import 'package:ai_talk_test/features/signals/data/datasources/signals_remote_data_source.dart';
import 'package:ai_talk_test/features/signals/data/repositories/signals_repository_impl.dart';
import 'package:ai_talk_test/features/signals/domain/usecases/load_signals.dart';
import 'package:ai_talk_test/features/signals/presentation/providers/signals_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (_) {
    return const Material(
      color: AppColors.canvas,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.ink, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => HttpApi(),
          dispose: (_, client) => client.close(),
        ),
        Provider(create: (_) => AuthLocalDataSource()),
        ChangeNotifierProvider(
          create: (context) {
            final repository = AuthRepositoryImpl(
              AuthRemoteDataSource(context.read<HttpApi>()),
              context.read<AuthLocalDataSource>(),
            );
            return AuthProvider(
              loginUser: LoginUser(repository),
              logoutUser: LogoutUser(repository),
              restoreSession: RestoreSession(repository),
            );
          },
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(
            LoadProfile(
              ProfileRepositoryImpl(
                ProfileRemoteDataSource(context.read<HttpApi>()),
              ),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => SignalsProvider(
            LoadSignals(
              SignalsRepositoryImpl(
                SignalsRemoteDataSource(context.read<HttpApi>()),
              ),
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => PromoProvider(
            LoadPromoMaterials(
              PromoRepositoryImpl(
                PromoRemoteDataSource(context.read<HttpApi>()),
              ),
            ),
          ),
        ),
      ],
      child: const _AppScale(child: _TalkApp()),
    );
  }
}

class _TalkApp extends StatelessWidget {
  const _TalkApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AITalk',
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

class _AppScale extends StatefulWidget {
  const _AppScale({required this.child});

  final Widget child;

  @override
  State<_AppScale> createState() => _AppScaleState();
}

class _AppScaleState extends State<_AppScale> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final view = View.maybeOf(context);
    if (view != null) {
      final media = MediaQueryData.fromView(view);
      final width = media.size.width.clamp(300.0, 430.0).toDouble();
      ScreenUtil.configure(
        data: media.copyWith(size: Size(width, media.size.height)),
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        fontSizeResolver: FontSizeResolvers.width,
      );
    }
    return widget.child;
  }
}
