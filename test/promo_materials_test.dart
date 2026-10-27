import 'package:ai_talk_test/core/network/api_end_point.dart';
import 'package:ai_talk_test/core/network/http_api.dart';
import 'package:ai_talk_test/features/promo/data/datasources/promo_remote_data_source.dart';
import 'package:ai_talk_test/features/promo/data/repositories/promo_repository_impl.dart';
import 'package:ai_talk_test/features/promo/domain/usecases/load_promo_materials.dart';
import 'package:ai_talk_test/features/promo/presentation/providers/promo_provider.dart';
import 'package:ai_talk_test/features/promo/presentation/screens/promo_materials_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const soap = '''
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
  <s:Body>
    <GetCCPromoResponse xmlns="http://tempuri.org/">
      <GetCCPromoResult>{"forex_copy": {"image": "https://example.com/copy.png","text": "Forex Copy - Professionals trade, you earn","link": "https://play.google.com/store/apps/details?id=com.instaforex.android.forexcopy&amp;hl=en","button_text": "Start earning today","button_color": "#3A469A","euro_available": False,"die_date": 0},"ended": {"image": "https://example.com/old.png","text": "Expired offer","link": "https://example.com/old","button_text": "Gone","button_color": "#000000","euro_available": False,"die_date": 1600000000}}</GetCCPromoResult>
    </GetCCPromoResponse>
  </s:Body>
</s:Envelope>''';

  test('GetCCPromo requests lang=en and parses materials', () async {
    late http.Request captured;
    final api = HttpApi(
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          soap,
          200,
          headers: {'content-type': 'text/xml; charset=utf-8'},
        );
      }),
    );

    final items = await PromoRemoteDataSource(api).getMaterials();

    expect(captured.url.toString(), ApiEndPoint.cabinetMicroServiceUrl);
    expect(captured.headers['soapaction'], ApiEndPoint.getCcPromoAction);
    expect(captured.body, contains('<tem:lang>en</tem:lang>'));
    expect(items, hasLength(1));
    expect(items.single.id, 'forex_copy');
    expect(items.single.text, 'Forex Copy - Professionals trade, you earn');
    expect(
      items.single.linkUrl,
      'https://play.google.com/store/apps/details?id=com.instaforex.android.forexcopy&hl=en',
    );
    expect(items.single.buttonText, 'Start earning today');
    expect(items.single.buttonColor, '#3A469A');
    api.close();
  });

  testWidgets('promo screen shows materials from GetCCPromo', (tester) async {
    tester.view.physicalSize = const Size(360, 690);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = HttpApi(
      client: MockClient((request) async {
        return http.Response(soap, 200);
      }),
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) {
          return ChangeNotifierProvider(
            create: (_) => PromoProvider(
              LoadPromoMaterials(
                PromoRepositoryImpl(PromoRemoteDataSource(api)),
              ),
            ),
            child: const MaterialApp(home: PromoMaterialsScreen()),
          );
        },
      ),
    );

    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Promo'), findsOneWidget);
    expect(
      find.text('Forex Copy - Professionals trade, you earn'),
      findsOneWidget,
    );
    expect(find.text('Start earning today'), findsOneWidget);
    expect(find.text('Expired offer'), findsNothing);

    api.close();
  });
}
