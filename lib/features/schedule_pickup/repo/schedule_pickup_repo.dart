import 'package:dio/dio.dart';
import 'package:suchigo_user_app/models/app_error_model.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/urls.dart';
import '../../profile/model/profile_model.dart';
import '../model/schedule_pickup_model.dart';

abstract class SchedulePickupRepository {
  Future<List<String>> getStates({Function(AppError error)? onError});
  Future<List<DistrictModel>> getDistrictsList(
      {String? state, Function(AppError error)? onError});
  Future<List<String>> getDistricts(String state,
      {Function(AppError error)? onError});
  Future<List<LocalBodyModel>> getLocalBodiesList(
      {int? districtId, String? district, Function(AppError error)? onError});
  Future<List<String>> getLocalBodies(String district,
      {int? districtId, Function(AppError error)? onError});
  Future<List<WardModel>> getWardsList(
      {int? localBodyId, String? localBody, Function(AppError error)? onError});
  Future<List<String>> getWards(String localBody,
      {int? localBodyId, Function(AppError error)? onError});
  Future<List<DisposalRateModel>> getDisposalRates(
      {Function(AppError error)? onError});
  Future<double?> getDisposalRateForLocalBody(int localBodyId,
      {Function(AppError error)? onError});
  Future<List<CalendarDateModel>> getCalendarDates(int localBodyId,
      {Function(AppError error)? onError});
  Future<ProfileResponseModel?> getUserProfile(
      {Function(AppError error)? onError});
  Future<PickupResponseModel?> submitPickupSchedule(
      SchedulePickupRequestModel request,
      {Function(AppError error)? onError});
}

class SchedulePickupRepositoryImpl implements SchedulePickupRepository {
  final WebAPIService _apiService;

  SchedulePickupRepositoryImpl({WebAPIService? apiService})
      : _apiService = apiService ?? WebAPIService();

  @override
  Future<List<String>> getStates({Function(AppError error)? onError}) async {
    await _apiService.initTokenToHeader();
    try {
      final response = await _apiService.dio.get(urlStates);
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

      final states = rawList
          .whereType<Map>()
          .map((item) => StateModel.fromJson(item).name)
          .where((name) => name.isNotEmpty)
          .toList();

      return states.isNotEmpty ? states : ['Kerala'];
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to load states',
        ));
      }
      return ['Kerala'];
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load states: $e'));
      }
      return ['Kerala'];
    }
  }

  @override
  Future<List<DistrictModel>> getDistrictsList(
      {String? state, Function(AppError error)? onError}) async {
    await _apiService.initTokenToHeader();
    try {
      final response = await _apiService.dio.get(urlDistricts);
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

      final districts = rawList
          .whereType<Map>()
          .map((item) => DistrictModel.fromJson(item))
          .where((item) => item.name.isNotEmpty)
          .toList();

      return districts;
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to load districts',
        ));
      }
      return [];
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load districts: $e'));
      }
      return [];
    }
  }

  @override
  Future<List<String>> getDistricts(String state,
      {Function(AppError error)? onError}) async {
    final list = await getDistrictsList(state: state, onError: onError);
    if (list.isNotEmpty) {
      return list.map((item) => item.name).toList();
    }
    return ['Ernakulam', 'Thrissur', 'Kottayam'];
  }

  @override
  Future<List<LocalBodyModel>> getLocalBodiesList({
    int? districtId,
    String? district,
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();

    int? targetDistrictId = districtId;
    if (targetDistrictId == null &&
        district != null &&
        district.isNotEmpty &&
        district != 'Not Selected') {
      try {
        final districts = await getDistrictsList();
        final match = districts.firstWhere(
          (d) => d.name.toLowerCase() == district.toLowerCase(),
          orElse: () => districts.isNotEmpty
              ? districts.first
              : const DistrictModel(id: 1, name: 'Ernakulam'),
        );
        targetDistrictId = match.id;
      } catch (_) {}
    }
    targetDistrictId ??= 1;

    try {
      final response = await _apiService.dio.get(
        urlLocalBodies,
        queryParameters: {'district_id': targetDistrictId},
      );
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

      final localBodies = rawList
          .whereType<Map>()
          .map((item) => LocalBodyModel.fromJson(item))
          .where((item) => item.name.isNotEmpty)
          .toList();

      return localBodies;
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to load local bodies',
        ));
      }
      return [];
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load local bodies: $e'));
      }
      return [];
    }
  }

  @override
  Future<List<String>> getLocalBodies(String district,
      {int? districtId, Function(AppError error)? onError}) async {
    final list = await getLocalBodiesList(
      districtId: districtId,
      district: district,
      onError: onError,
    );
    if (list.isNotEmpty) {
      return list.map((item) => item.name).toList();
    }
    return [
      'Alangad Panchayat',
      'Aluva Municipality',
      'Angamaly Municipality',
      'Cheranalloor Grama Panchayat',
      'Choornikkara Gram Panchayat',
      'Edathala Gram Panchayat',
    ];
  }

  @override
  Future<List<WardModel>> getWardsList({
    int? localBodyId,
    String? localBody,
    Function(AppError error)? onError,
  }) async {
    await _apiService.initTokenToHeader();

    int? targetLocalBodyId = localBodyId;
    if (targetLocalBodyId == null &&
        localBody != null &&
        localBody.isNotEmpty &&
        localBody != 'Not Selected') {
      try {
        final localBodies = await getLocalBodiesList();
        final match = localBodies.firstWhere(
          (lb) => lb.name.toLowerCase() == localBody.toLowerCase(),
          orElse: () => localBodies.isNotEmpty
              ? localBodies.first
              : const LocalBodyModel(id: 2, name: 'Aluva Municipality'),
        );
        targetLocalBodyId = match.id;
      } catch (_) {}
    }
    targetLocalBodyId ??= 2;

    try {
      final response = await _apiService.dio.get(
        urlWards,
        queryParameters: {
          'local_body_id': targetLocalBodyId,
          'localbody_id': targetLocalBodyId,
        },
      );
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

      final wards = rawList
          .whereType<Map>()
          .map((item) => WardModel.fromJson(item))
          .where((item) => item.wardName.isNotEmpty)
          .toList();

      return wards;
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to load wards',
        ));
      }
      return [];
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load wards: $e'));
      }
      return [];
    }
  }

  @override
  Future<List<String>> getWards(String localBody,
      {int? localBodyId, Function(AppError error)? onError}) async {
    final list = await getWardsList(
      localBodyId: localBodyId,
      localBody: localBody,
      onError: onError,
    );
    if (list.isNotEmpty) {
      return list.map((item) => item.displayName).toList();
    }
    return [
      'Ward 1 - Neericode West',
      'Ward 2 - Neericode East',
      'Ward 3 - Panchayat Head Quarters',
    ];
  }

  List<DisposalRateModel>? _cachedDisposalRates;

  @override
  Future<List<DisposalRateModel>> getDisposalRates(
      {Function(AppError error)? onError}) async {
    if (_cachedDisposalRates != null && _cachedDisposalRates!.isNotEmpty) {
      return _cachedDisposalRates!;
    }
    await _apiService.initTokenToHeader();
    try {
      final response = await _apiService.dio.get(urlDisposalRates);
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

      final rates = rawList
          .whereType<Map>()
          .map((item) => DisposalRateModel.fromJson(item))
          .toList();

      _cachedDisposalRates = rates;
      return rates;
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to load disposal rates',
        ));
      }
      return [];
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load disposal rates: $e'));
      }
      return [];
    }
  }

  @override
  Future<double?> getDisposalRateForLocalBody(int localBodyId,
      {Function(AppError error)? onError}) async {
    final rates = await getDisposalRates(onError: onError);
    try {
      final match = rates.firstWhere(
        (r) => r.localBodyId == localBodyId,
      );
      return match.ratePerKg;
    } catch (_) {
      return 40.0;
    }
  }

  @override
  Future<List<CalendarDateModel>> getCalendarDates(int localBodyId,
      {Function(AppError error)? onError}) async {
    await _apiService.initTokenToHeader();
    try {
      final response = await _apiService.dio.get(
        urlCalendarDates,
        queryParameters: {'local_body_id': localBodyId},
      );
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

      final dates = rawList
          .whereType<Map>()
          .map(CalendarDateModel.tryFromJson)
          .whereType<CalendarDateModel>()
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      return dates;
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to load pickup dates',
        ));
      }
      return [];
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load pickup dates: $e'));
      }
      return [];
    }
  }

  @override
  Future<ProfileResponseModel?> getUserProfile(
      {Function(AppError error)? onError}) async {
    await _apiService.initTokenToHeader();
    try {
      final response = await _apiService.dio.get(urlProfile);
      if (response.data is Map) {
        return ProfileResponseModel.fromJson(response.data as Map);
      }
      return null;
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to load profile',
        ));
      }
      return null;
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to load profile: $e'));
      }
      return null;
    }
  }

  @override
  Future<PickupResponseModel?> submitPickupSchedule(
      SchedulePickupRequestModel request,
      {Function(AppError error)? onError}) async {
    await _apiService.initTokenToHeader();
    try {
      final payload = request.toJson();
      final response = await _apiService.dio.post(
        urlPickups,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map) {
          return PickupResponseModel.fromJson(response.data as Map);
        }
      }
      return null;
    } on DioException catch (e) {
      if (onError != null) {
        final errorMsg = e.response?.data is Map
            ? (e.response?.data['message']?.toString() ??
                e.response?.data['error']?.toString() ??
                e.response?.data.toString())
            : null;
        onError(AppError(
          message: errorMsg ?? e.message ?? 'Failed to schedule pickup',
        ));
      }
      return null;
    } catch (e) {
      if (onError != null) {
        onError(AppError(message: 'Failed to schedule pickup: $e'));
      }
      return null;
    }
  }
}
