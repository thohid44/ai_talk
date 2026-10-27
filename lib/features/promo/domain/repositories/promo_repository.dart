import 'package:ai_talk_test/features/promo/domain/entities/cc_promo.dart';

abstract class PromoRepository {
  Future<List<CcPromo>> getMaterials({String lang = 'en'});
}
