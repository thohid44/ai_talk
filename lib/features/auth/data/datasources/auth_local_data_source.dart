import 'package:ai_talk_test/features/auth/domain/entities/client_session.dart';
import 'package:ai_talk_test/features/auth/domain/entities/passkey.dart';
import 'package:get_storage/get_storage.dart';

class AuthLocalDataSource {
  AuthLocalDataSource([GetStorage? box]) : _box = box ?? GetStorage();

  static const _loginKey = 'login';
  static const _tokenKey = 'token';
  static const _passkeyKey = 'passkey';
  static const _passkeyExpiryKey = 'passkeyExpiresAt';

  final GetStorage _box;

  ClientSession? readSession() {
    final login = _box.read(_loginKey);
    final token = _box.read(_tokenKey);
    final parsedLogin = login is int
        ? login
        : login is num
        ? login.toInt()
        : null;
    if (parsedLogin == null || token is! String || token.trim().isEmpty) {
      return null;
    }
    return ClientSession(login: parsedLogin, token: token.trim());
  }

  Future<void> saveSession(ClientSession session) async {
    await _box.write(_loginKey, session.login);
    await _box.write(_tokenKey, session.token);
  }

  Passkey? readPasskey() {
    final key = _box.read(_passkeyKey);
    final expiry = _box.read(_passkeyExpiryKey);
    if (key is! String || key.trim().isEmpty || expiry is! String) return null;
    final expiresAt = DateTime.tryParse(expiry);
    if (expiresAt == null || !DateTime.now().isBefore(expiresAt)) return null;
    return Passkey(value: key.trim(), expiresAt: expiresAt.toLocal());
  }

  Future<void> savePasskey(Passkey passkey) async {
    await _box.write(_passkeyKey, passkey.value);
    await _box.write(
      _passkeyExpiryKey,
      passkey.expiresAt.toUtc().toIso8601String(),
    );
  }

  Future<void> clear() async {
    await _box.remove(_loginKey);
    await _box.remove(_tokenKey);
    await _box.remove(_passkeyKey);
    await _box.remove(_passkeyExpiryKey);
  }
}
