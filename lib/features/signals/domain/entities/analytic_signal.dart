class AnalyticSignal {
  const AnalyticSignal({
    required this.pair,
    this.direction,
    this.openPrice,
    this.takeProfit,
    this.stopLoss,
    this.time,
    this.note,
    this.date,
  });

  final String pair;
  final String? direction;
  final String? openPrice;
  final String? takeProfit;
  final String? stopLoss;
  final String? time;
  final String? note;
  final DateTime? date;
}
