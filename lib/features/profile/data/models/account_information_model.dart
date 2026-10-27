import 'package:ai_talk_test/features/profile/domain/entities/account_information.dart';

class AccountInformationModel {
  static AccountInformation fromJson(Map<String, dynamic> json) {
    return AccountInformation(
      address: _text(json['address']),
      balance: _number(json['balance']),
      city: _text(json['city']),
      country: _text(json['country']),
      currency: _integer(json['currency']),
      currentTradesCount: _integer(json['currentTradesCount']),
      currentTradesVolume: _number(json['currentTradesVolume']),
      equity: _number(json['equity']),
      freeMargin: _number(json['freeMargin']),
      isAnyOpenTrades: _boolean(json['isAnyOpenTrades']),
      isSwapFree: _boolean(json['isSwapFree']),
      leverage: _integer(json['leverage']),
      name: _text(json['name']),
      phone: _text(json['phone']),
      totalTradesCount: _integer(json['totalTradesCount']),
      totalTradesVolume: _number(json['totalTradesVolume']),
      type: _integer(json['type']),
      verificationLevel: _integer(json['verificationLevel']),
      zipCode: _text(json['zipCode']),
    );
  }
}

String? _text(dynamic value) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return null;
}

double? _number(dynamic value) {
  if (value is num) return value.toDouble();
  return null;
}

int? _integer(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}

bool? _boolean(dynamic value) {
  if (value is bool) return value;
  return null;
}
