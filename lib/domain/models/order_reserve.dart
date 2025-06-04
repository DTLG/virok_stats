class OrderReserve {
  final int delayCount;
  final int reservCount;

  OrderReserve({
    required this.delayCount,
    required this.reservCount,
  });

  factory OrderReserve.fromJson(Map<String, dynamic> json) {
    return OrderReserve(
      delayCount: json['delay_count'] ?? 0,
      reservCount: json['reserv_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'delay_count': delayCount,
      'reserv_count': reservCount,
    };
  }
}
