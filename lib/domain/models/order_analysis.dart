class OrderAnalysis {
  final String name;
  final double amountStorage;
  final double count;
  final double reserv;
  final double sumPrice;

  OrderAnalysis({
    required this.name,
    required this.amountStorage,
    required this.count,
    required this.reserv,
    required this.sumPrice,
  });

  factory OrderAnalysis.fromJson(Map<String, dynamic> json) {
    return OrderAnalysis(
      name: json['Name'] ?? '',
      amountStorage: (json['amount_storage'] ?? 0).toDouble(),
      count: (json['count'] ?? 0).toDouble(),
      reserv: (json['reserv'] ?? 0).toDouble(),
      sumPrice: (json['sum_price'] ?? 0).toDouble(),
    );
  }
}
