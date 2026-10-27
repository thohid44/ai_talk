class AccountInformation {
  const AccountInformation({
    this.address,
    this.balance,
    this.city,
    this.country,
    this.currency,
    this.currentTradesCount,
    this.currentTradesVolume,
    this.equity,
    this.freeMargin,
    this.isAnyOpenTrades,
    this.isSwapFree,
    this.leverage,
    this.name,
    this.phone,
    this.totalTradesCount,
    this.totalTradesVolume,
    this.type,
    this.verificationLevel,
    this.zipCode,
  });

  final String? address;
  final double? balance;
  final String? city;
  final String? country;
  final int? currency;
  final int? currentTradesCount;
  final double? currentTradesVolume;
  final double? equity;
  final double? freeMargin;
  final bool? isAnyOpenTrades;
  final bool? isSwapFree;
  final int? leverage;
  final String? name;
  final String? phone;
  final int? totalTradesCount;
  final double? totalTradesVolume;
  final int? type;
  final int? verificationLevel;
  final String? zipCode;
}
