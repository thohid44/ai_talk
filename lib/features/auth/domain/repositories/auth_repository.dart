import 'package:ai_talk_test/features/auth/domain/entities/client_session.dart';
import 'package:ai_talk_test/features/auth/domain/entities/credentials.dart';
import 'package:ai_talk_test/features/auth/domain/entities/passkey.dart';

abstract class AuthRepository {
  Future<Credentials> verifyCredentials({
    required int login,
    required String password,
  });

  Future<String> requestPasskey({required int login, required String password});

  Future<void> saveSession(ClientSession session);

  ClientSession? readSession();

  Future<void> savePasskey(Passkey passkey);

  Passkey? readPasskey();

  Future<void> clear();
}
