import 'package:ai_talk_test/features/auth/domain/entities/client_session.dart';
import 'package:ai_talk_test/features/auth/domain/entities/passkey.dart';
import 'package:ai_talk_test/features/auth/domain/repositories/auth_repository.dart';

class RestoredSession {
  const RestoredSession({this.session, this.passkey});

  final ClientSession? session;
  final Passkey? passkey;
}

class RestoreSession {
  RestoreSession(this._repository);

  final AuthRepository _repository;

  RestoredSession call() {
    final session = _repository.readSession();
    if (session == null) return const RestoredSession();
    return RestoredSession(
      session: session,
      passkey: _repository.readPasskey(),
    );
  }
}
