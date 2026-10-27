import 'package:ai_talk_test/core/error/failure.dart';
import 'package:ai_talk_test/core/network/api_exceptions.dart';
import 'package:ai_talk_test/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ai_talk_test/features/profile/domain/entities/account_information.dart';
import 'package:ai_talk_test/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<AccountInformation> getAccount({
    required int login,
    required String token,
  }) {
    return _guard(() => _remote.getAccount(login: login, token: token));
  }

  @override
  Future<String?> getPhone({required int login, required String token}) {
    return _guard(() async {
      final value = await _remote.getPhone(login: login, token: token);
      return _cleanPhone(value);
    });
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on ApiException catch (error) {
      throw Failure(error.message, statusCode: error.statusCode);
    }
  }

  String? _cleanPhone(String value) {
    var text = value.trim();
    if (text.length >= 2 && text.startsWith('"') && text.endsWith('"')) {
      text = text.substring(1, text.length - 1).trim();
    }
    if (text.isEmpty) return null;
    return text;
  }
}
