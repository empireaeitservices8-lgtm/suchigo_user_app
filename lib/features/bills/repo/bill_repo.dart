import 'package:dio/dio.dart';
import 'package:suchigo_user_app/models/app_error_model.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/urls.dart';
import '../model/bill_model.dart';

abstract class BillRepository {
  Future<BillsSummaryModel> getBillsSummary({
    Function(AppError error)? onError,
  });
}

class BillRepositoryImpl implements BillRepository {
  final WebAPIService _apiService;

  BillRepositoryImpl({WebAPIService? apiService})
      : _apiService = apiService ?? WebAPIService();

  @override
  Future<BillsSummaryModel> getBillsSummary({
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();
    try {
      final response = await _apiService.dio.get(urlBills);
      if (response.data is List) {
        return BillsSummaryModel.fromList(response.data as List);
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map.containsKey('data') && map['data'] is List) {
          return BillsSummaryModel.fromList(map['data'] as List);
        } else if (map.containsKey('results') && map['results'] is List) {
          return BillsSummaryModel.fromList(map['results'] as List);
        }
      }
      return const BillsSummaryModel();
    } on DioException catch (e) {
      if (onError != null) {
        onError(AppError(
          message: e.response?.data?['message']?.toString() ??
              e.message ??
              'Failed to load bills',
        ));
      }
      return const BillsSummaryModel();
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load bills: $e'));
      }
      return const BillsSummaryModel();
    }
  }
}
