import 'package:ai_talk_test/core/error/failure.dart';
import 'package:ai_talk_test/features/signals/domain/entities/analytic_signal.dart';
import 'package:ai_talk_test/features/signals/domain/usecases/load_signals.dart';
import 'package:flutter/foundation.dart';

class SignalsProvider extends ChangeNotifier {
  SignalsProvider(this._loadSignals);

  final LoadSignals _loadSignals;

  List<AnalyticSignal> signals = const [];
  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  int _requestId = 0;

  Future<void> load({
    required int login,
    required String partnerToken,
    required String pair,
    required DateTime from,
    required DateTime to,
  }) async {
    final requestId = ++_requestId;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final loaded = await _loadSignals(
        login: login,
        partnerToken: partnerToken,
        pair: pair,
        from: from,
        to: to,
      );
      if (requestId != _requestId) return;
      signals = loaded;
      hasLoaded = true;
    } on Failure catch (error) {
      if (requestId != _requestId) return;
      signals = const [];
      hasLoaded = true;
      errorMessage =
          readableApiMessage(error.message) ??
          'Signals archive is not available.';
    } catch (_) {
      if (requestId != _requestId) return;
      signals = const [];
      hasLoaded = true;
      errorMessage = 'Unable to reach the signals service.';
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void clear() {
    _requestId++;
    signals = const [];
    isLoading = false;
    hasLoaded = false;
    errorMessage = null;
    notifyListeners();
  }
}
