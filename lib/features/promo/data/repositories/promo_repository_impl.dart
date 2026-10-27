import 'package:ai_talk_test/core/error/failure.dart';
import 'package:ai_talk_test/core/network/api_exceptions.dart';
import 'package:ai_talk_test/features/promo/data/datasources/promo_remote_data_source.dart';
import 'package:ai_talk_test/features/promo/domain/entities/cc_promo.dart';
import 'package:ai_talk_test/features/promo/domain/repositories/promo_repository.dart';

class PromoRepositoryImpl implements PromoRepository {
  PromoRepositoryImpl(this._remote);

  final PromoRemoteDataSource _remote;

  @override
  Future<List<CcPromo>> getMaterials({String lang = 'en'}) async {
    try {
      return await _remote.getMaterials(lang: lang);
    } on ApiException catch (error) {
      throw Failure(error.message, statusCode: error.statusCode);
    }
  }
}
