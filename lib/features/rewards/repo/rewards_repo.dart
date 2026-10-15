import 'package:suchigo_user_app/models/app_error_model.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/urls.dart';
import '../model/rewards_model.dart';

abstract class RewardsRepository {
  Future<RewardsSummaryModel> getRewardsData({
    Function(AppError error)? onError,
  });
}

class RewardsRepositoryImpl implements RewardsRepository {
  final WebAPIService _apiService;

  RewardsRepositoryImpl({WebAPIService? apiService})
      : _apiService = apiService ?? WebAPIService();

  @override
  Future<RewardsSummaryModel> getRewardsData({
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();
    int pickupCount = 0;

    try {
      final response = await _apiService.dio.get(urlPickups);
      if (response.data is List) {
        final list = (response.data as List).whereType<Map>().toList();
        pickupCount = list.length;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['data'] is List) {
          pickupCount = (map['data'] as List).length;
        } else if (map['results'] is List) {
          pickupCount = (map['results'] as List).length;
        }
      }
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load pickups: $e'));
      }
    }

    // Each completed/created pickup adds 25 points, base default 50 points
    final points = pickupCount > 0 ? (pickupCount * 25) : 50;

    const defaultVouchers = [
      EcoVoucherModel(
        id: 'voucher_100_bill',
        title: '₹100 Bill Discount',
        description: 'Get ₹100 off your next garbage collection bill.',
        requiredPoints: 200,
      ),
      EcoVoucherModel(
        id: 'voucher_compost_kit',
        title: 'Free Organic Compost Kit',
        description:
            'Get a 2kg pack of organic home composting starter kit.',
        requiredPoints: 300,
      ),
      EcoVoucherModel(
        id: 'voucher_green_partner',
        title: '15% Off GreenPartner Store',
        description:
            'Discount on eco-friendly grocery and household goods.',
        requiredPoints: 450,
      ),
    ];

    return RewardsSummaryModel(
      totalPoints: points,
      milestoneTarget: 500,
      vouchers: defaultVouchers,
      totalPickups: pickupCount,
    );
  }
}
