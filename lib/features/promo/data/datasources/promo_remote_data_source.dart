import 'package:ai_talk_test/core/network/api_end_point.dart';
import 'package:ai_talk_test/core/network/api_exceptions.dart';
import 'package:ai_talk_test/core/network/http_api.dart';
import 'package:ai_talk_test/features/promo/data/models/cc_promo_model.dart';
import 'package:ai_talk_test/features/promo/domain/entities/cc_promo.dart';

class PromoRemoteDataSource {
  PromoRemoteDataSource(this._http);

  final HttpApi _http;

  Future<List<CcPromo>> getMaterials({String lang = 'en'}) async {
    final response = await _http.postCabinet(
      uri: Uri.parse(ApiEndPoint.cabinetMicroServiceUrl),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': ApiEndPoint.getCcPromoAction,
      },
      body: _ccPromoEnvelope(lang),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _soapFault(response.body) ?? 'Request failed (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
    final fault = _soapFault(response.body);
    if (fault != null) {
      throw ApiException(fault, statusCode: response.statusCode);
    }
    try {
      return CcPromoModel.listFromSoap(response.body);
    } on FormatException {
      throw ApiException('The promo service returned an unreadable response.');
    }
  }

  String _ccPromoEnvelope(String lang) {
    return '''<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
  <soapenv:Header/>
  <soapenv:Body>
    <tem:GetCCPromo>
      <tem:lang>${_xmlEscape(lang)}</tem:lang>
    </tem:GetCCPromo>
  </soapenv:Body>
</soapenv:Envelope>''';
  }
}

String _xmlEscape(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}

String _xmlDecode(String value) {
  return value
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&');
}

String? _soapFault(String body) {
  final match = RegExp(
    r'<faultstring\b[^>]*>([\s\S]*?)</faultstring>',
  ).firstMatch(body);
  if (match == null) return null;
  final text = _xmlDecode(match.group(1)!.trim());
  if (text.isEmpty) return 'The promo service returned an error.';
  return text;
}
