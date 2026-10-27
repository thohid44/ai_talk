import 'package:ai_talk_test/core/error/failure.dart';
import 'package:ai_talk_test/features/profile/domain/entities/account_information.dart';
import 'package:ai_talk_test/features/profile/domain/repositories/profile_repository.dart';

class ProfileLoadResult {
  const ProfileLoadResult({
    this.account,
    this.phone,
    this.accountError,
    this.phoneError,
  });

  final AccountInformation? account;
  final String? phone;
  final String? accountError;
  final String? phoneError;
}

class LoadProfile {
  LoadProfile(this._repository);

  final ProfileRepository _repository;

  Future<ProfileLoadResult> call({
    required int login,
    required String token,
  }) async {
    AccountInformation? account;
    String? phone;
    String? accountError;
    String? phoneError;

    try {
      account = await _repository.getAccount(login: login, token: token);
    } on Failure catch (error) {
      accountError = error.message;
    } catch (_) {
      accountError = 'Unable to reach the server.';
    }

    try {
      phone = await _repository.getPhone(login: login, token: token);
    } on Failure catch (error) {
      phoneError = error.message;
    } catch (_) {
      phoneError = 'Unable to reach the server.';
    }

    return ProfileLoadResult(
      account: account,
      phone: phone,
      accountError: accountError,
      phoneError: phoneError,
    );
  }
}
