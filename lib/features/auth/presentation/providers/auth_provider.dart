import 'package:ai_talk_test/core/error/failure.dart';
import 'package:ai_talk_test/features/auth/domain/entities/client_session.dart';
import 'package:ai_talk_test/features/auth/domain/usecases/login_user.dart';
import 'package:ai_talk_test/features/auth/domain/usecases/logout_user.dart';
import 'package:ai_talk_test/features/auth/domain/usecases/restore_session.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required LoginUser loginUser,
    required LogoutUser logoutUser,
    required RestoreSession restoreSession,
  }) : _loginUser = loginUser,
       _logoutUser = logoutUser,
       _restoreSession = restoreSession;

  final LoginUser _loginUser;
  final LogoutUser _logoutUser;
  final RestoreSession _restoreSession;

  ClientSession? session;
  String? passkey;
  DateTime? passkeyExpiresAt;
  bool passkeyUnavailable = false;
  bool isSubmitting = false;
  String? errorMessage;

  bool get isLoggedIn => session != null;

  bool get hasValidPasskey {
    final key = passkey?.trim();
    final expiry = passkeyExpiresAt;
    if (key == null || key.isEmpty || expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  Future<bool> login({required int login, required String password}) async {
    if (isSubmitting) return false;

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _loginUser(login: login, password: password);
      session = result.session;
      passkey = result.passkey?.value;
      passkeyExpiresAt = result.passkey?.expiresAt;
      passkeyUnavailable = result.passkeyUnavailable;
      return true;
    } on Failure catch (error) {
      errorMessage =
          readableApiMessage(error.message) ??
          'Unable to sign in. Please try again.';
      return false;
    } catch (_) {
      errorMessage = 'Unable to reach the server. Please try again.';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void restore() {
    final restored = _restoreSession();
    if (restored.session == null) return;
    session = restored.session;
    final storedPasskey = restored.passkey;
    if (storedPasskey != null) {
      passkey = storedPasskey.value;
      passkeyExpiresAt = storedPasskey.expiresAt;
      passkeyUnavailable = false;
    }
    notifyListeners();
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    session = null;
    passkey = null;
    passkeyExpiresAt = null;
    passkeyUnavailable = false;
    errorMessage = null;
    isSubmitting = false;
    notifyListeners();
    await _logoutUser();
  }
}
