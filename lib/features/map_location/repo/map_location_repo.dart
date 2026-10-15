import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model/map_location_model.dart';

abstract class MapLocationRepository {
  Future<SelectedAddressModel> getAddressFromCoordinates(
      double lat, double lng);
  Future<List<SelectedAddressModel>> searchPlaces(String query);
  Future<SelectedAddressModel> getPlaceDetails(String placeId);
  String getStaticMapUrl(double lat, double lng, {int zoom = 14, int width = 600, int height = 600});
}

class MapLocationRepositoryImpl implements MapLocationRepository {
  static const String googleMapsApiKey =
      'AIzaSyCtm-MkEfqf97QQgsuL7KI1J0ei6xEJY9Q';

  final Dio _dio;

  MapLocationRepositoryImpl({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {'accept': 'application/json'},
              ),
            );

  @override
  String getStaticMapUrl(double lat, double lng,
      {int zoom = 14, int width = 600, int height = 600}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=$zoom&size=${width}x$height&scale=2&maptype=roadmap&key=$googleMapsApiKey';
  }

  @override
  Future<SelectedAddressModel> getAddressFromCoordinates(
      double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': googleMapsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          final results = data['results'] as List;
          // Prefer result that is a street address, premise, subpremise or locality
          Map<String, dynamic> chosenResult = results[0];
          for (var item in results) {
            final types = (item['types'] as List? ?? []).cast<String>();
            final addr = item['formatted_address'] as String? ?? '';
            // If first result is just a Plus Code, prefer a richer address
            if (!RegExp(r'^[A-Z0-9]{4,8}\+[A-Z0-9]{2,4}').hasMatch(addr)) {
              if (types.contains('street_address') ||
                  types.contains('premise') ||
                  types.contains('subpremise') ||
                  types.contains('route') ||
                  types.contains('sublocality_level_1')) {
                chosenResult = item;
                break;
              }
            }
          }
          return _parseGeocodeResult(chosenResult, lat, lng);
        }
      }
    } catch (e) {
      debugPrint('[MapLocationRepo] Geocode error: $e');
    }

    // Fallback coordinates if network/API limits reached
    return SelectedAddressModel(
      fullAddress: '9F, Kakkanad, Keralam, 682303, India',
      street: '9F',
      area: 'Kakkanad',
      city: 'Kochi',
      state: 'Kerala',
      zipCode: '682303',
      latitude: lat,
      longitude: lng,
    );
  }

  @override
  Future<List<SelectedAddressModel>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query.trim(),
          'key': googleMapsApiKey,
          'components': 'country:in',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == 'OK' && data['predictions'] != null) {
          final predictions = data['predictions'] as List;
          return predictions.map<SelectedAddressModel>((item) {
            final structured = item['structured_formatting'] ?? {};
            final mainText = structured['main_text'] ?? item['description'] ?? '';
            final secondaryText = structured['secondary_text'] ?? '';
            final fullDesc = item['description'] ?? mainText;
            final placeId = item['place_id'] as String?;

            return SelectedAddressModel(
              fullAddress: fullDesc,
              street: '',
              area: mainText.isNotEmpty ? mainText : secondaryText,
              city: secondaryText,
              state: 'Kerala',
              zipCode: '',
              latitude: 10.1132,
              longitude: 76.2894,
              placeId: placeId,
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('[MapLocationRepo] Places Autocomplete error: $e');
    }

    return [];
  }

  @override
  Future<SelectedAddressModel> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'fields': 'geometry,formatted_address,address_components,name',
          'key': googleMapsApiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'];
          final location = result['geometry']?['location'] ?? {};
          final double lat = (location['lat'] as num?)?.toDouble() ?? 10.1132;
          final double lng = (location['lng'] as num?)?.toDouble() ?? 76.2894;
          return _parseGeocodeResult(result, lat, lng, placeId: placeId);
        }
      }
    } catch (e) {
      debugPrint('[MapLocationRepo] Place Details error: $e');
    }

    return const SelectedAddressModel(
      fullAddress: 'Selected Location',
      area: 'Selected Location',
      zipCode: '',
      latitude: 10.1132,
      longitude: 76.2894,
    );
  }

  SelectedAddressModel _parseGeocodeResult(
    Map<String, dynamic> result,
    double fallbackLat,
    double fallbackLng, {
    String? placeId,
  }) {
    String fullAddress =
        result['formatted_address'] as String? ?? 'Selected Location';
    // Clean raw Plus Code prefix if present (e.g. "56VR+67 ")
    fullAddress = fullAddress.replaceFirst(
        RegExp(r'^[A-Z0-9]{4,8}\+[A-Z0-9]{2,4},?\s*'), '');
    if (fullAddress.isEmpty) fullAddress = 'Selected Location';

    final components = result['address_components'] as List? ?? [];

    String street = '';
    String area = '';
    String city = '';
    String state = '';
    String zipCode = '';

    for (var comp in components) {
      final types = (comp['types'] as List? ?? []).cast<String>();
      final longName = comp['long_name'] as String? ?? '';

      if (types.contains('postal_code')) {
        zipCode = longName;
      } else if (types.contains('sublocality_level_1') ||
          types.contains('sublocality') ||
          types.contains('neighborhood')) {
        if (area.isEmpty) area = longName;
      } else if (types.contains('locality')) {
        city = longName;
        if (area.isEmpty) area = longName;
      } else if (types.contains('administrative_area_level_2')) {
        if (city.isEmpty) city = longName;
      } else if (types.contains('administrative_area_level_1')) {
        state = longName;
      } else if (types.contains('route') || types.contains('premise')) {
        street = longName;
      }
    }

    if (area.isEmpty) {
      area = result['name'] as String? ?? (city.isNotEmpty ? city : 'Selected Location');
    }

    final location = result['geometry']?['location'];
    final lat = (location?['lat'] as num?)?.toDouble() ?? fallbackLat;
    final lng = (location?['lng'] as num?)?.toDouble() ?? fallbackLng;

    return SelectedAddressModel(
      fullAddress: fullAddress,
      street: street,
      area: area,
      city: city,
      state: state,
      zipCode: zipCode,
      latitude: lat,
      longitude: lng,
      placeId: placeId ?? result['place_id'] as String?,
    );
  }
}

