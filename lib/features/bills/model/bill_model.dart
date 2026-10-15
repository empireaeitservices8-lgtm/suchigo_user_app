enum BillStatus {
  all,
  pending,
  paid,
}

class BillModel {
  final int id;
  final double amount;
  final String paymentMethod;
  final String transactionId;
  final double weight;
  final double rate;
  final String dueDate;
  final bool isPaid;
  final String paymentGateway;
  final String remarks;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;
  final String description;
  final String createdAt;
  final int? user;

  const BillModel({
    required this.id,
    required this.amount,
    this.paymentMethod = '',
    this.transactionId = '',
    this.weight = 0.0,
    this.rate = 0.0,
    required this.dueDate,
    required this.isPaid,
    this.paymentGateway = '',
    this.remarks = '',
    this.razorpayOrderId = '',
    this.razorpayPaymentId = '',
    this.razorpaySignature = '',
    this.description = '',
    this.createdAt = '',
    this.user,
  });

  BillStatus get status => isPaid ? BillStatus.paid : BillStatus.pending;

  String get invoiceNumber => transactionId.isNotEmpty
      ? transactionId
      : 'INV-${id.toString().padLeft(4, '0')}';

  String get dateString => dueDate.isNotEmpty ? dueDate : createdAt;

  factory BillModel.fromJson(Map<dynamic, dynamic> json) => BillModel(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        amount: double.tryParse(json['amount']?.toString() ??
                json['total_amount']?.toString() ??
                '') ??
            0.0,
        paymentMethod: json['payment_method']?.toString() ?? '',
        transactionId: json['transaction_id']?.toString() ?? '',
        weight: double.tryParse(json['weight']?.toString() ?? '') ?? 0.0,
        rate: double.tryParse(json['rate']?.toString() ?? '') ?? 0.0,
        dueDate: json['due_date']?.toString() ?? '',
        isPaid: json['is_paid'] == true ||
            json['is_paid']?.toString().toLowerCase() == 'true' ||
            json['payment_status']?.toString().toLowerCase() == 'paid',
        paymentGateway: json['payment_gateway']?.toString() ?? '',
        remarks: json['remarks']?.toString() ?? '',
        razorpayOrderId: json['razorpay_order_id']?.toString() ?? '',
        razorpayPaymentId: json['razorpay_payment_id']?.toString() ?? '',
        razorpaySignature: json['razorpay_signature']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        createdAt: json['created_at']?.toString() ?? '',
        user: int.tryParse(json['user']?.toString() ?? ''),
      );
}

class BillsSummaryModel {
  final double pendingBills;
  final double paidThisMonth;
  final List<BillModel> bills;

  const BillsSummaryModel({
    this.pendingBills = 0.00,
    this.paidThisMonth = 0.00,
    this.bills = const [],
  });

  factory BillsSummaryModel.fromList(List<dynamic> list) {
    final bills = list
        .whereType<Map>()
        .map((item) => BillModel.fromJson(item))
        .toList();

    double pending = 0.0;
    double paid = 0.0;

    for (final bill in bills) {
      if (bill.isPaid) {
        paid += bill.amount;
      } else {
        pending += bill.amount;
      }
    }

    return BillsSummaryModel(
      pendingBills: pending,
      paidThisMonth: paid,
      bills: bills,
    );
  }
}
