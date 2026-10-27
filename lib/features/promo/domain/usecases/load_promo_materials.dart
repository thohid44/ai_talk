import 'package:ai_talk_test/features/promo/domain/entities/cc_promo.dart';
import 'package:ai_talk_test/features/promo/domain/repositories/promo_repository.dart';

class LoadPromoMaterials {
  LoadPromoMaterials(this._repository);

  final PromoRepository _repository;

  Future<List<CcPromo>> call({String lang = 'en'}) {
    return _repository.getMaterials(lang: lang);
  }
}
