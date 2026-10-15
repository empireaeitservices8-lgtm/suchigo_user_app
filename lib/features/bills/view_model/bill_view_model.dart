import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/bill_model.dart';
import '../repo/bill_repo.dart';

class BillViewModel extends ViewModel {
  final BillRepository _repository;

  BillsSummaryModel _summary = const BillsSummaryModel();
  BillStatus _selectedFilter = BillStatus.all;
  String? _errorMessage;

  BillViewModel({BillRepository? repository})
      : _repository = repository ?? BillRepositoryImpl() {
    loadBills();
  }

  BillsSummaryModel get summary => _summary;
  BillStatus get selectedFilter => _selectedFilter;
  String? get errorMessage => _errorMessage;

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

  Future<void> loadBills() async {
    isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _repository.getBillsSummary(
        onError: (error) {
          _errorMessage = error.message;
        },
      );
    } catch (e) {
      _summary = const BillsSummaryModel();
      _errorMessage ??= 'Failed to load bills';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
