import 'package:ai_talk_test/features/profile/domain/entities/account_information.dart';

abstract class ProfileRepository {
  Future<AccountInformation> getAccount({
    required int login,
    required String token,
  });

  Future<String?> getPhone({required int login, required String token});
}
