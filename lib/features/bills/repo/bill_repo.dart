import '../model/bill_model.dart';

abstract class BillRepository {
  Future<BillsSummaryModel> getBillsSummary();
}

class BillRepositoryImpl implements BillRepository {
  @override
  Future<BillsSummaryModel> getBillsSummary() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const BillsSummaryModel(
      pendingBills: 0.00,
      paidThisMonth: 0.00,
      bills: [],
    );
  }
}
