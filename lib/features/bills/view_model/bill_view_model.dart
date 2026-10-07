import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/bill_model.dart';
import '../repo/bill_repo.dart';

class BillViewModel extends ViewModel {
  final BillRepository _repository;

  BillsSummaryModel _summary = const BillsSummaryModel();
  BillStatus _selectedFilter = BillStatus.all;

  BillViewModel({BillRepository? repository})
      : _repository = repository ?? BillRepositoryImpl() {
    loadBills();
  }

  BillsSummaryModel get summary => _summary;
  BillStatus get selectedFilter => _selectedFilter;

  List<BillModel> get filteredBills {
    if (_selectedFilter == BillStatus.all) {
      return _summary.bills;
    }
    return _summary.bills.where((b) => b.status == _selectedFilter).toList();
  }

  void setFilter(BillStatus filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  void loadBills() async {
    isLoading = true;
    try {
      _summary = await _repository.getBillsSummary();
    } catch (e) {
      _summary = const BillsSummaryModel();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
