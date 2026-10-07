enum OrderStatus {
  all,
  completed,
  pending,
  cancelled,
}

class OrderModel {
  final String id;
  final String code;
  final int count;
  final OrderStatus status;
  final String dateString;
  final String address;
  final double weightKg;

  const OrderModel({
    required this.id,
    required this.code,
    this.count = 1,
    required this.status,
    required this.dateString,
    required this.address,
    this.weightKg = 0.0,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.all:
        return 'all';
    }
  }
}
