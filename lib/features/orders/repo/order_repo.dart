import '../model/order_model.dart';

abstract class OrderRepository {
  Future<List<OrderModel>> getOrders();
}

class OrderRepositoryImpl implements OrderRepository {
  @override
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      OrderModel(
        id: '1',
        code: 'WC-94',
        count: 1,
        status: OrderStatus.pending,
        dateString: '21 Sep 2026',
        address: '294H+W56, Kochi, Keralam, 683565, India, Ernakulam',
        weightKg: 0.0,
      ),
      OrderModel(
        id: '2',
        code: 'WC-115',
        count: 1,
        status: OrderStatus.pending,
        dateString: '2 Oct 2026',
        address: '9F, Kakkanad, Keralam, 682303, India, Ernakulam',
        weightKg: 0.0,
      ),
    ];
  }
}
