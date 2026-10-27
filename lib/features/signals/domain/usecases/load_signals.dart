import 'package:ai_talk_test/features/signals/domain/entities/analytic_signal.dart';
import 'package:ai_talk_test/features/signals/domain/repositories/signals_repository.dart';

class LoadSignals {
  LoadSignals(this._repository);

  final SignalsRepository _repository;

  Future<List<AnalyticSignal>> call({
    required int login,
    required String partnerToken,
    required String pair,
    required DateTime from,
    required DateTime to,
  }) {
    return _repository.getSignals(
      login: login,
      partnerToken: partnerToken,
      pair: pair,
      from: from,
      to: to,
    );
  }
}
