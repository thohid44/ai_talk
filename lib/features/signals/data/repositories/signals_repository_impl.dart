import 'package:ai_talk_test/core/error/failure.dart';
import 'package:ai_talk_test/core/network/api_exceptions.dart';
import 'package:ai_talk_test/features/signals/data/datasources/signals_remote_data_source.dart';
import 'package:ai_talk_test/features/signals/domain/entities/analytic_signal.dart';
import 'package:ai_talk_test/features/signals/domain/repositories/signals_repository.dart';

class SignalsRepositoryImpl implements SignalsRepository {
  SignalsRepositoryImpl(this._remote);

  final SignalsRemoteDataSource _remote;

  @override
  Future<List<AnalyticSignal>> getSignals({
    required int login,
    required String partnerToken,
    required String pair,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      return await _remote.getSignals(
        login: login,
        partnerToken: partnerToken,
        pair: pair,
        from: from,
        to: to,
      );
    } on ApiException catch (error) {
      throw Failure(error.message, statusCode: error.statusCode);
    }
  }
}
