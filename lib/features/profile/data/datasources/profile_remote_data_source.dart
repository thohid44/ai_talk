import 'package:ai_talk_test/core/network/api_end_point.dart';
import 'package:ai_talk_test/core/network/http_api.dart';
import 'package:ai_talk_test/features/profile/data/models/account_information_model.dart';
import 'package:ai_talk_test/features/profile/domain/entities/account_information.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource(this._http);

  final HttpApi _http;

  Future<AccountInformation> getAccount({
    required int login,
    required String token,
  }) async {
    final data = await _http.postObject(
      _http.baseUri(ApiEndPoint.getAccountInformation),
      {'login': login, 'token': token},
    );
    return AccountInformationModel.fromJson(data);
  }

  Future<String> getPhone({required int login, required String token}) {
    return _http.postText(_http.baseUri(ApiEndPoint.getLastFourNumbersPhone), {
      'login': login,
      'token': token,
    });
  }
}
