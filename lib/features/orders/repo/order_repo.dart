import 'package:dio/dio.dart';
import 'package:suchigo_user_app/features/profile/model/profile_model.dart';
import 'package:suchigo_user_app/helpers/sp_helper.dart';
import 'package:suchigo_user_app/models/app_error_model.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/urls.dart';
import '../model/order_model.dart';
import '../model/pickup_vehicle_tracking_model.dart';

abstract class OrderRepository {
  Future<String?> getUserName();

  Future<List<OrderModel>> getOrders({
    Function(AppError error)? onError,
  });

  Future<PickupVehicleTrackingModel?> getPickupVehicleTracking(
    int pickupId, {
    Function(AppError error)? onError,
  });
}

class OrderRepositoryImpl implements OrderRepository {
  final WebAPIService _apiService;

  OrderRepositoryImpl({WebAPIService? apiService})
      : _apiService = apiService ?? WebAPIService();

  @override
  Future<String?> getUserName() async {
    try {
      final cached = await SpHelper.getString('KEY_USER_NAME');
      if (cached != null && cached.isNotEmpty && cached.toUpperCase() != 'USER') {
        return cached.toUpperCase();
      }
      await _apiService.initTokenToHeader();
      final response = await _apiService.dio.get(urlProfile);
      if (response.data is Map) {
        final profile = ProfileResponseModel.fromJson(response.data as Map);
        String name = '';
        if (profile.fullName.isNotEmpty &&
            profile.fullName.toLowerCase() != 'user') {
          name = profile.fullName.toUpperCase();
        } else if (profile.user?.firstName != null &&
            profile.user!.firstName!.isNotEmpty) {
          final lastName = profile.user?.lastName ?? '';
          name = '${profile.user!.firstName!} $lastName'.trim().toUpperCase();
        } else if (profile.username.isNotEmpty) {
          name = profile.username.toUpperCase();
        }
        if (name.isNotEmpty) {
          await SpHelper.saveString('KEY_USER_NAME', name);
          return name;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<List<OrderModel>> getOrders({
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();
    try {
      final response = await _apiService.dio.get(urlPickups);
      if (response.data is List) {
        return (response.data as List)
            .whereType<Map>()
            .map((e) => OrderModel.fromJson(e))
            .toList();
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map.containsKey('data') && map['data'] is List) {
          return (map['data'] as List)
              .whereType<Map>()
              .map((e) => OrderModel.fromJson(e))
              .toList();
        } else if (map.containsKey('results') && map['results'] is List) {
          return (map['results'] as List)
              .whereType<Map>()
              .map((e) => OrderModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      if (onError != null) {
        onError(AppError(
          message: e.response?.data?['message']?.toString() ??
              e.message ??
              'Failed to load pickup history',
        ));
      }
      return [];
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load pickup history: $e'));
      }
      return [];
    }
  }

  @override
  Future<PickupVehicleTrackingModel?> getPickupVehicleTracking(
    int pickupId, {
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();
    try {
      final response = await _apiService.dio.get(
        urlPickupVehicleTracking,
        queryParameters: {'pickup_id': pickupId},
      );

      if (response.data is Map) {
        return PickupVehicleTrackingModel.fromJson(response.data as Map);
      }
      return null;
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to fetch tracking details',
        ));
      }
      return null;
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to fetch tracking details: $e'));
      }
      return null;
    }
  }
}
