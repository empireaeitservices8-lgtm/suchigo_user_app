enum BillStatus {
  all,
  pending,
  paid,
}

class BillModel {
  final String id;
  final String invoiceNumber;
  final double amount;
  final String dateString;
  final BillStatus status;

  const BillModel({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.dateString,
    required this.status,
  });
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
}
