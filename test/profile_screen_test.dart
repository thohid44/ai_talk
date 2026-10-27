import 'dart:convert';

import 'package:ai_talk_test/core/network/http_api.dart';
import 'package:ai_talk_test/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ai_talk_test/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ai_talk_test/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ai_talk_test/features/auth/domain/entities/client_session.dart';
import 'package:ai_talk_test/features/auth/domain/usecases/login_user.dart';
import 'package:ai_talk_test/features/auth/domain/usecases/logout_user.dart';
import 'package:ai_talk_test/features/auth/domain/usecases/restore_session.dart';
import 'package:ai_talk_test/features/auth/presentation/providers/auth_provider.dart';
import 'package:ai_talk_test/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ai_talk_test/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ai_talk_test/features/profile/domain/usecases/load_profile.dart';
import 'package:ai_talk_test/features/profile/presentation/providers/profile_provider.dart';
import 'package:ai_talk_test/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('account response parses', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'name': 'Test Account',
          'balance': 2796.24,
          'leverage': 150,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final api = HttpApi(client: client);
    try {
      final account = await ProfileRemoteDataSource(
        api,
      ).getAccount(login: 1, token: 'token');
      expect(account.name, 'Test Account');
    } catch (error, stack) {
      fail('$error\n$stack');
    } finally {
      api.close();
    }
  });

  Future<void> pumpProfile(
    WidgetTester tester, {
    required Size size,
    required MockClient client,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = HttpApi(client: client);
    addTearDown(api.close);
    final authRepository = AuthRepositoryImpl(
      AuthRemoteDataSource(api),
      AuthLocalDataSource(),
    );
    final auth = AuthProvider(
      loginUser: LoginUser(authRepository),
      logoutUser: LogoutUser(authRepository),
      restoreSession: RestoreSession(authRepository),
    )..session = const ClientSession(login: 20234561, token: 'token');

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: auth),
              ChangeNotifierProvider(
                create: (_) => ProfileProvider(
                  LoadProfile(
                    ProfileRepositoryImpl(ProfileRemoteDataSource(api)),
                  ),
                ),
              ),
            ],
            child: MaterialApp(
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF0E2A47),
                ).copyWith(primary: const Color(0xFF0E2A47)),
              ),
              home: child,
            ),
          );
        },
        child: const ProfileScreen(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
  }

  testWidgets('profile shows account details and masked phone', (tester) async {
    final paths = <String>[];
    final client = MockClient((request) async {
      paths.add(request.url.toString());
      if (request.url.path.endsWith('GetLastFourNumbersPhone')) {
        return http.Response(jsonEncode('********0000'), 200);
      }
      return http.Response(
        jsonEncode({
          'address': '15 Aldanskaya St',
          'balance': 2796.24,
          'city': 'Kaliningrad',
          'country': 'Russia',
          'currency': 0,
          'currentTradesCount': 0,
          'currentTradesVolume': 0,
          'equity': 2796.24,
          'freeMargin': 2796.24,
          'isAnyOpenTrades': false,
          'isSwapFree': false,
          'leverage': 150,
          'name': 'Test Account',
          'totalTradesCount': 12,
          'totalTradesVolume': 360,
          'type': 1,
          'verificationLevel': 0,
          'zipCode': 'ru236013',
        }),
        200,
      );
    });

    await pumpProfile(tester, size: const Size(320, 640), client: client);

    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .toList();
    expect(
      texts,
      contains('Test Account'),
      reason: 'paths=$paths texts=$texts',
    );
    expect(find.text('Login ID 20234561'), findsOneWidget);
    expect(find.text('2,796.24'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('1:150'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('1:150'), findsOneWidget);
    expect(find.text('********0000'), findsOneWidget);
    expect(find.text('Russia'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile keeps the phone when account details fail', (
    tester,
  ) async {
    final client = MockClient((request) async {
      if (request.url.path.endsWith('GetLastFourNumbersPhone')) {
        return http.Response(jsonEncode('********5520'), 200);
      }
      return http.Response('"Internal server error"', 500);
    });

    await pumpProfile(tester, size: const Size(412, 800), client: client);

    expect(find.text('My account'), findsOneWidget);
    expect(find.text('********5520'), findsOneWidget);
    expect(find.text('Account details could not be loaded.'), findsOneWidget);
    expect(find.text('Internal server error'), findsOneWidget);
    expect(find.text('Balance'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
