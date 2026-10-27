import 'package:ai_talk_test/core/network/api_end_point.dart';
import 'package:ai_talk_test/core/network/http_api.dart';
import 'package:ai_talk_test/features/auth/domain/entities/credentials.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._http);

  final HttpApi _http;

  Future<Credentials> verifyCredentials({
    required int login,
    required String password,
  }) async {
    final data = await _http.postObject(
      _http.baseUri(ApiEndPoint.isAccountCredentialsCorrect),
      {'login': login, 'password': password},
      successCodes: const {200, 401},
    );
    final token = data['token'];
    return Credentials(
      result: data['result'] == true,
      token: token is String ? token : '',
    );
  }

  Future<String> requestPasskey({
    required int login,
    required String password,
  }) {
    return _http.postText(
      _http.clientUri(ApiEndPoint.requestMobileCabinetApiToken),
      {'Login': login.toString(), 'Password': password},
    );
  }
}
