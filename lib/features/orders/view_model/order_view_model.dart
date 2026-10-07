import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/order_model.dart';
import '../repo/order_repo.dart';

class OrderViewModel extends ViewModel {
  final OrderRepository _repository;

  List<OrderModel> _allOrders = [];
  OrderStatus _selectedFilter = OrderStatus.all;

  OrderViewModel({OrderRepository? repository})
      : _repository = repository ?? OrderRepositoryImpl() {
    loadOrders();
  }

  OrderStatus get selectedFilter => _selectedFilter;

  List<OrderModel> get filteredOrders {
    if (_selectedFilter == OrderStatus.all) {
      return _allOrders;
    }
    return _allOrders.where((o) => o.status == _selectedFilter).toList();
  }

  void setFilter(OrderStatus filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  void loadOrders() async {
    isLoading = true;
    try {
      _allOrders = await _repository.getOrders();
    } catch (e) {
      _allOrders = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
