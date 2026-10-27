import 'package:ai_talk_test/core/error/failure.dart';
import 'package:ai_talk_test/features/auth/domain/entities/client_session.dart';
import 'package:ai_talk_test/features/profile/domain/entities/account_information.dart';
import 'package:ai_talk_test/features/profile/domain/usecases/load_profile.dart';
import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._loadProfile);

  final LoadProfile _loadProfile;

  AccountInformation? account;
  String? phone;
  bool isLoading = false;
  String? errorMessage;
  String? warningMessage;
  String? statusDetail;
  int _requestId = 0;

  bool get hasDetails =>
      account != null || (phone != null && phone!.trim().isNotEmpty);

  Future<void> load(ClientSession? session) async {
    final requestId = ++_requestId;
    final token = session?.token.trim();
    if (session == null || token == null || token.isEmpty) {
      account = null;
      phone = null;
      errorMessage = null;
      warningMessage = null;
      statusDetail = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    warningMessage = null;
    statusDetail = null;
    notifyListeners();

    final result = await _loadProfile(login: session.login, token: token);
    if (requestId != _requestId) return;

    if (result.account != null) account = result.account;
    if (result.phoneError == null) phone = result.phone;

    final accountError = _friendly(result.accountError);
    final phoneError = _friendly(result.phoneError);
    final nothingToShow = account == null && (phone == null || phone!.isEmpty);
    final detail = _serverDetail(accountError) ?? _serverDetail(phoneError);
    if (accountError != null && phoneError != null && nothingToShow) {
      errorMessage = 'Unable to load your profile. Please try again.';
      statusDetail = detail;
    } else if (accountError != null && phoneError != null) {
      warningMessage = 'Some profile details could not be refreshed.';
      statusDetail = detail;
    } else if (accountError != null) {
      warningMessage = 'Account details could not be loaded.';
      statusDetail = _serverDetail(accountError);
    } else if (phoneError != null) {
      warningMessage = 'Phone number could not be loaded.';
      statusDetail = _serverDetail(phoneError);
    }

    isLoading = false;
    notifyListeners();
  }

  void clear() {
    _requestId++;
    account = null;
    phone = null;
    errorMessage = null;
    warningMessage = null;
    statusDetail = null;
    isLoading = false;
    notifyListeners();
  }

  String? _friendly(String? message) {
    if (message == null) return null;
    return readableApiMessage(message) ??
        'The server could not return this profile data.';
  }

  String? _serverDetail(String? message) {
    if (message == null) return null;
    final text = readableApiMessage(message);
    if (text == null) return null;
    if (text == 'Unable to reach the server.') return text;
    if (text == 'The server could not return this profile data.') return null;
    return text;
  }
}
