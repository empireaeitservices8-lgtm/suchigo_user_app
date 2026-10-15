import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/order_model.dart';
import '../repo/order_repo.dart';

class OrderViewModel extends ViewModel {
  final OrderRepository _repository;

  List<OrderModel> _allOrders = [];
  OrderStatus _selectedFilter = OrderStatus.all;
  String _userName = 'User';
  String? errorMessage;

  OrderViewModel({OrderRepository? repository})
      : _repository = repository ?? OrderRepositoryImpl() {
    loadOrders();
  }

  OrderStatus get selectedFilter => _selectedFilter;
  String get userName => _userName;

  List<OrderModel> get filteredOrders {
    if (_selectedFilter == OrderStatus.all) {
      return _allOrders;
    }
    return _allOrders.where((o) => o.orderStatus == _selectedFilter).toList();
  }

  void setFilter(OrderStatus filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getUserName(),
        _repository.getOrders(
          onError: (err) {
            errorMessage = err.message;
          },
        ),
      ]);

      final fetchedName = results[0] as String?;
      _allOrders = results[1] as List<OrderModel>;

      if (fetchedName != null && fetchedName.isNotEmpty && fetchedName != 'USER') {
        _userName = fetchedName;
      } else if (_allOrders.isNotEmpty &&
          _allOrders.first.fullName.isNotEmpty &&
          _allOrders.first.fullName.toLowerCase() != 'user') {
        _userName = _allOrders.first.fullName.toUpperCase();
      }
    } catch (e) {
      _allOrders = [];
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
