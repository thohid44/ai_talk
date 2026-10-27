import 'package:ai_talk_test/core/error/failure.dart';
import 'package:ai_talk_test/core/network/api_exceptions.dart';
import 'package:ai_talk_test/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:ai_talk_test/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ai_talk_test/features/auth/domain/entities/client_session.dart';
import 'package:ai_talk_test/features/auth/domain/entities/credentials.dart';
import 'package:ai_talk_test/features/auth/domain/entities/passkey.dart';
import 'package:ai_talk_test/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<Credentials> verifyCredentials({
    required int login,
    required String password,
  }) {
    return _guard(
      () => _remote.verifyCredentials(login: login, password: password),
    );
  }

  @override
  Future<String> requestPasskey({
    required int login,
    required String password,
  }) {
    return _guard(
      () => _remote.requestPasskey(login: login, password: password),
    );
  }

  @override
  Future<void> saveSession(ClientSession session) {
    return _local.saveSession(session);
  }

  @override
  ClientSession? readSession() => _local.readSession();

  @override
  Future<void> savePasskey(Passkey passkey) => _local.savePasskey(passkey);

  @override
  Passkey? readPasskey() => _local.readPasskey();

  @override
  Future<void> clear() => _local.clear();

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw Failure(error.message, statusCode: error.statusCode);
    }
  }
}
