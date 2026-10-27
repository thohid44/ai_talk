import 'package:ai_talk_test/core/error/failure.dart';
import 'package:ai_talk_test/features/promo/domain/entities/cc_promo.dart';
import 'package:ai_talk_test/features/promo/domain/usecases/load_promo_materials.dart';
import 'package:flutter/foundation.dart';

class PromoProvider extends ChangeNotifier {
  PromoProvider(this._loadPromoMaterials);

  final LoadPromoMaterials _loadPromoMaterials;

  List<CcPromo> materials = const [];
  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  int _requestId = 0;

  Future<void> load({String lang = 'en'}) async {
    final requestId = ++_requestId;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final loaded = await _loadPromoMaterials(lang: lang);
      if (requestId != _requestId) return;
      materials = loaded;
      hasLoaded = true;
    } on Failure catch (error) {
      if (requestId != _requestId) return;
      materials = const [];
      hasLoaded = true;
      errorMessage =
          readableApiMessage(error.message) ??
          (error.statusCode != null && error.statusCode! >= 500
              ? 'The promo service could not return materials.'
              : 'Unable to load promo materials.');
    } catch (_) {
      if (requestId != _requestId) return;
      materials = const [];
      hasLoaded = true;
      errorMessage = 'Unable to reach the promo service.';
    } finally {
      if (requestId == _requestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void clear() {
    _requestId++;
    materials = const [];
    isLoading = false;
    hasLoaded = false;
    errorMessage = null;
    notifyListeners();
  }
}
