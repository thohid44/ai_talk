import 'package:ai_talk_test/core/network/api_end_point.dart';
import 'package:ai_talk_test/core/network/api_exceptions.dart';
import 'package:ai_talk_test/core/network/http_api.dart';
import 'package:ai_talk_test/features/signals/data/models/analytic_signal_model.dart';
import 'package:ai_talk_test/features/signals/domain/entities/analytic_signal.dart';

class SignalsRemoteDataSource {
  SignalsRemoteDataSource(this._http);

  final HttpApi _http;

  Future<List<AnalyticSignal>> getSignals({
    required int login,
    required String partnerToken,
    required String pair,
    required DateTime from,
    required DateTime to,
  }) async {
    final uri = _http
        .partnerUri(ApiEndPoint.analyticSignals(login))
        .replace(
          queryParameters: {
            'tradingsystem': '3',
            'pairs': pair,
            'from': '${_unixStart(from)}',
            'to': '${_unixEnd(to)}',
          },
        );
    final response = await _http.get(
      uri,
      headers: {'passkey': partnerToken, 'Accept': 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _http.errorMessage(response),
        statusCode: response.statusCode,
      );
    }
    return AnalyticSignalModel.listFrom(
      _http.decodeBody(response.body),
      fallbackPair: pair,
    );
  }

  int _unixStart(DateTime date) {
    return DateTime.utc(
          date.year,
          date.month,
          date.day,
        ).millisecondsSinceEpoch ~/
        1000;
  }

  int _unixEnd(DateTime date) {
    return DateTime.utc(
          date.year,
          date.month,
          date.day,
          23,
          59,
          59,
        ).millisecondsSinceEpoch ~/
        1000;
  }
}
