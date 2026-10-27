import 'package:ai_talk_test/features/signals/domain/entities/analytic_signal.dart';

abstract class SignalsRepository {
  Future<List<AnalyticSignal>> getSignals({
    required int login,
    required String partnerToken,
    required String pair,
    required DateTime from,
    required DateTime to,
  });
}
