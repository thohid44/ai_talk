import 'package:ai_talk_test/features/auth/domain/repositories/auth_repository.dart';

class LogoutUser {
  LogoutUser(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.clear();
}
