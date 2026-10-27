import 'package:ai_talk_test/core/error/failure.dart';
import 'package:ai_talk_test/features/auth/domain/entities/client_session.dart';
import 'package:ai_talk_test/features/auth/domain/entities/passkey.dart';
import 'package:ai_talk_test/features/auth/domain/repositories/auth_repository.dart';

class LoginResult {
  const LoginResult({
    required this.session,
    this.passkey,
    required this.passkeyUnavailable,
  });

  final ClientSession session;
  final Passkey? passkey;
  final bool passkeyUnavailable;
}

class LoginUser {
  LoginUser(this._repository);

  final AuthRepository _repository;

  Future<LoginResult> call({
    required int login,
    required String password,
  }) async {
    final credentials = await _repository.verifyCredentials(
      login: login,
      password: password,
    );
    if (!credentials.isSuccess) {
      throw Failure('Login ID or password is incorrect');
    }

    final session = ClientSession(login: login, token: credentials.token);
    await _repository.saveSession(session);

    Passkey? passkey;
    var passkeyUnavailable = false;
    try {
      final key = await _repository.requestPasskey(
        login: login,
        password: password,
      );
      final trimmed = key.trim();
      if (trimmed.isEmpty) {
        passkeyUnavailable = true;
      } else {
        passkey = Passkey(
          value: trimmed,
          expiresAt: DateTime.now().add(const Duration(minutes: 90)),
        );
        await _repository.savePasskey(passkey);
      }
    } catch (_) {
      passkeyUnavailable = true;
    }

    return LoginResult(
      session: session,
      passkey: passkey,
      passkeyUnavailable: passkeyUnavailable,
    );
  }
}
