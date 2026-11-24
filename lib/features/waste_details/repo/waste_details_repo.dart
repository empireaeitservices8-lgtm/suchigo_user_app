import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:suchigo_user_app/models/app_error_model.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/urls.dart';
import '../model/waste_details_model.dart';

abstract class WasteDetailsRepository {
  Future<List<WasteCategoryDetailModel>> getWasteCategories(
      WastePropertyType type);
  Future<List<SubWasteRateModel>> getSubWasteRates({
    String? categoryId,
    Function(AppError error)? onError,
  });
}

class WasteDetailsRepositoryImpl implements WasteDetailsRepository {
  final WebAPIService _apiService;

  WasteDetailsRepositoryImpl({WebAPIService? apiService})
      : _apiService = apiService ?? WebAPIService();

  @override
  Future<List<WasteCategoryDetailModel>> getWasteCategories(
      WastePropertyType type) async {
    int sanitaryId = 4;
    int solidId = 3;
    int organicId = 1;
    int eWasteId = 13;

    try {
      final response = await _apiService.dio.get(urlWasteTypes);
      List rawList = [];
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        if (response.data['data'] is List) {
          rawList = response.data['data'] as List;
        } else if (response.data['results'] is List) {
          rawList = response.data['results'] as List;
        }
      }

      for (var item in rawList) {
        if (item is Map) {
          final id = int.tryParse(item['id']?.toString() ?? '');
          final name = (item['name']?.toString() ?? '').toLowerCase();
          if (id != null) {
            if (name.contains('sanitary') ||
                name.contains('daiper') ||
                name.contains('diaper') ||
                name.contains('pad')) {
              sanitaryId = id;
            } else if (name.contains('organic') || name.contains('compost')) {
              organicId = id;
            } else if (name.contains('e-waste') || name.contains('electronic')) {
              eWasteId = id;
            } else if (name.contains('solid') || name.contains('hazard')) {
              solidId = id;
            }
          }
        }
      }
    } catch (_) {}

    return [
      WasteCategoryDetailModel(
        id: 'sanitary',
        wasteTypeId: sanitaryId,
        title: 'SANITARY WASTE',
        description: 'Diaper, Sanitary Pad,\nExpired Medicine, Hair Waste',
        icon: Icons.baby_changing_station,
        isEnabled: true,
      ),
      WasteCategoryDetailModel(
        id: 'solid',
        wasteTypeId: solidId,
        title: 'SOLID WASTE',
        description: 'Paper, Plastic, Metals,\nE-Waste, Glass, Wood',
        icon: Icons.delete_outline_rounded,
        isEnabled: false,
      ),
      WasteCategoryDetailModel(
        id: 'organic',
        wasteTypeId: organicId,
        title: 'ORGANIC WASTE',
        description: 'Food Scraps, Garden\nWaste, Compostables',
        icon: Icons.eco_outlined,
        isEnabled: false,
      ),
      WasteCategoryDetailModel(
        id: 'e_waste',
        wasteTypeId: eWasteId,
        title: 'E-WASTE',
        description: 'Electronics, Batteries,\nCables, Old Devices',
        icon: Icons.devices_other_outlined,
        isEnabled: false,
      ),
    ];
  }

  @override
  Future<List<SubWasteRateModel>> getSubWasteRates({
    String? categoryId,
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();

    try {
      final response = await _apiService.dio.get(urlSubWasteTypes);
      List rawList = [];
      if (response.data is List) {
        rawList = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['data'] is List) {
          rawList = map['data'] as List;
        } else if (map['results'] is List) {
          rawList = map['results'] as List;
        }
      }

      if (rawList.isNotEmpty) {
        return rawList
            .whereType<Map>()
            .map((item) => SubWasteRateModel.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to load sub-waste types',
        ));
      }
      return [];
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load sub-waste types: $e'));
      }
      return [];
    }
  }
}
