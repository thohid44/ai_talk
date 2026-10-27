import 'dart:convert';

import 'package:ai_talk_test/features/signals/domain/entities/analytic_signal.dart';

class AnalyticSignalModel {
  static List<AnalyticSignal> listFrom(
    dynamic decoded, {
    String? fallbackPair,
  }) {
    return [
      for (final item in _signalList(decoded))
        if (item is Map)
          fromMap(Map<String, dynamic>.from(item), fallbackPair: fallbackPair),
    ].where((signal) => signal.pair.isNotEmpty).toList();
  }

  static AnalyticSignal fromMap(
    Map<String, dynamic> json, {
    String? fallbackPair,
  }) {
    final pair =
        _pick(json, const [
          'symbol',
          'pair',
          'currency',
          'instrument',
          'symbolname',
          'ticker',
        ]) ??
        fallbackPair ??
        '';
    final time = _pick(json, const [
      'openTime',
      'actualTime',
      'time',
      'signalTime',
      'date',
    ]);
    return AnalyticSignal(
      pair: pair,
      direction: _directionLabel(
        _pick(json, const ['direction', 'orderType', 'cmd', 'action', 'type']),
      ),
      openPrice: _pick(json, const ['openPrice', 'price', 'open']),
      takeProfit: _pick(json, const ['takeProfit', 'tp']),
      stopLoss: _pick(json, const ['stopLoss', 'sl']),
      time: time,
      note: _pick(json, const ['comment', 'note', 'description']),
      date: _parseSignalDate(time),
    );
  }
}

List<dynamic> _signalList(dynamic decoded) {
  if (decoded is List) return decoded;
  if (decoded is String) {
    final nested = _jsonDecodeOrNull(decoded);
    if (nested != null) return _signalList(nested);
    return const [];
  }
  if (decoded is Map) {
    for (final key in const ['signals', 'result', 'data', 'items', 'value']) {
      for (final entry in decoded.entries) {
        if (entry.key.toString().toLowerCase() == key && entry.value is List) {
          return entry.value as List;
        }
      }
    }
    List<dynamic>? lists;
    for (final value in decoded.values) {
      if (value is List && (lists == null || value.length > lists.length)) {
        lists = value;
      }
    }
    if (lists != null) return lists;
    final map = Map<String, dynamic>.from(decoded);
    if (_pick(map, const ['symbol', 'pair', 'currency', 'instrument']) !=
        null) {
      return [decoded];
    }
  }
  return const [];
}

dynamic _jsonDecodeOrNull(String body) {
  try {
    return jsonDecode(body);
  } catch (_) {
    return null;
  }
}

String? _pick(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    for (final entry in json.entries) {
      if (entry.key.toString().toLowerCase() != key.toLowerCase()) continue;
      final value = entry.value;
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty || text == 'null') return null;
      return text;
    }
  }
  return null;
}

String? _directionLabel(String? value) {
  if (value == null) return null;
  final normalized = value.toLowerCase();
  if (normalized == '0' || normalized == 'buy' || normalized == 'long') {
    return 'Buy';
  }
  if (normalized == '1' || normalized == 'sell' || normalized == 'short') {
    return 'Sell';
  }
  return value;
}

DateTime? _parseSignalDate(String? value) {
  if (value == null) return null;
  final microsoft = RegExp(r'/Date\((-?\d+)').firstMatch(value);
  if (microsoft != null) {
    final millis = int.tryParse(microsoft.group(1)!);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    }
  }
  final asInt = int.tryParse(value);
  if (asInt != null) {
    final millis = asInt > 9999999999 ? asInt : asInt * 1000;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }
  return DateTime.tryParse(value);
}
