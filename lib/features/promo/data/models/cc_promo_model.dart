import 'dart:convert';

import 'package:ai_talk_test/features/promo/domain/entities/cc_promo.dart';

class CcPromoModel {
  static List<CcPromo> listFromSoap(String body) {
    final match = RegExp(
      r'<GetCCPromoResult\b([^>]*)>([\s\S]*?)</GetCCPromoResult>',
    ).firstMatch(body);
    if (match == null) return const [];
    if ((match.group(1) ?? '').contains('nil="true"')) return const [];

    final payload = _relaxJson(_xmlDecode(match.group(2)!.trim()));
    if (payload.isEmpty) return const [];

    final decoded = jsonDecode(payload);
    final items = <CcPromo>[];
    if (decoded is Map) {
      for (final entry in decoded.entries) {
        if (entry.value is! Map) continue;
        final item = fromMap(
          Map<String, dynamic>.from(entry.value as Map),
          id: entry.key.toString(),
        );
        if (item.isVisible) items.add(item);
      }
    } else if (decoded is List) {
      for (var index = 0; index < decoded.length; index++) {
        final value = decoded[index];
        if (value is! Map) continue;
        final item = fromMap(Map<String, dynamic>.from(value), id: '$index');
        if (item.isVisible) items.add(item);
      }
    }
    return items;
  }

  static CcPromo fromMap(Map<String, dynamic> json, {required String id}) {
    final dieDate = _integer(json['die_date']);
    if (!_promoIsActive(dieDate)) {
      return CcPromo(id: id);
    }
    return CcPromo(
      id: id,
      text: _text(json['text']),
      imageUrl: _text(json['image']),
      linkUrl: _text(json['link']),
      buttonText: _text(json['button_text']),
      buttonColor: _text(json['button_color']),
    );
  }
}

String _relaxJson(String value) {
  return value.replaceAllMapped(RegExp(r':\s*(True|False|None)\b'), (match) {
    switch (match.group(1)) {
      case 'True':
        return ': true';
      case 'False':
        return ': false';
      default:
        return ': null';
    }
  });
}

bool _promoIsActive(int? dieDate) {
  if (dieDate == null || dieDate <= 0) return true;
  if (dieDate < 1000000000) return true;
  final millis = dieDate > 9999999999 ? dieDate : dieDate * 1000;
  return DateTime.fromMillisecondsSinceEpoch(
    millis,
    isUtc: true,
  ).isAfter(DateTime.now().toUtc());
}

String? _text(dynamic value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

int? _integer(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

String _xmlDecode(String value) {
  return value
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&');
}
