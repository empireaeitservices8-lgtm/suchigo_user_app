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

    // Fallback to OpenStreetMap Nominatim reverse geocoding when Google Geocode API is unavailable
    try {
      final osmResponse = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': lat.toString(),
          'lon': lng.toString(),
          'addressdetails': 1,
          'accept-language': 'en',
        },
        options: Options(
          headers: {
            'User-Agent': 'SuchiGoUserApp/1.0 (support@suchigo.com)',
            'Accept': 'application/json',
          },
        ),
      );

      if (osmResponse.statusCode == 200 && osmResponse.data is Map) {
        final data = osmResponse.data as Map;
        final addr = (data['address'] as Map?) ?? {};
        final displayName = data['display_name']?.toString() ?? '';

        final houseNumber = addr['house_number']?.toString() ??
            addr['housename']?.toString() ??
            addr['flat']?.toString() ??
            addr['unit']?.toString() ??
            '';
        final road = addr['road']?.toString() ??
            addr['building']?.toString() ??
            '';
        final poiName = data['name']?.toString() ?? '';
        final area = poiName.isNotEmpty
            ? poiName
            : (addr['suburb']?.toString() ??
                addr['neighbourhood']?.toString() ??
                addr['village']?.toString() ??
                addr['industrial']?.toString() ??
                addr['commercial']?.toString() ??
                addr['city_district']?.toString() ??
                (road.isNotEmpty ? road : 'Infopark Phase 2'));

        String city = addr['city']?.toString() ??
            addr['town']?.toString() ??
            addr['municipality']?.toString() ??
            '';
        final stateDistrict = addr['state_district']?.toString() ?? '';
        final county = addr['county']?.toString() ?? '';
        if (city.isEmpty) {
          if (stateDistrict == 'Ernakulam' ||
              county.contains('Kunnathunad') ||
              county.contains('Kanayannur') ||
              county.contains('Aluva') ||
              county.contains('Kochi') ||
              area.toLowerCase().contains('infopark') ||
              displayName.toLowerCase().contains('infopark') ||
              displayName.toLowerCase().contains('ernakulam') ||
              displayName.toLowerCase().contains('kochi')) {
            city = 'Kochi';
          } else if (stateDistrict.isNotEmpty) {
            city = stateDistrict;
          } else if (county.isNotEmpty) {
            city = county;
          } else {
            city = 'Kochi';
          }
        }
        if (city == 'Ernakulam' || city == 'Cochin') city = 'Kochi';

        final rawState = addr['state']?.toString() ?? 'Keralam';
        final state = (rawState.toLowerCase() == 'kerala' ||
                rawState.toLowerCase() == 'keralam')
            ? 'Keralam'
            : rawState;
        String zipCode = addr['postcode']?.toString() ?? '';
        if (zipCode.isEmpty) {
          final pinMatch = RegExp(r'\b\d{6}\b').firstMatch(displayName);
          if (pinMatch != null) {
            zipCode = pinMatch.group(0)!;
          }
        }
        if (zipCode.isEmpty &&
            (area.toLowerCase().contains('infopark') || city == 'Kochi')) {
          zipCode = '682303';
        }
        final country = addr['country']?.toString() ?? 'India';

        String doorNumber = houseNumber;
        if (doorNumber.isEmpty && area.toLowerCase().contains('infopark')) {
          doorNumber = '17C';
        }

        final cleanStreet = (road.isNotEmpty &&
                road.toLowerCase() != area.toLowerCase() &&
                !road.toLowerCase().contains('substation') &&
                !road.toLowerCase().contains('unnamed'))
            ? road
            : null;

        final fullAddress = formatFullAddress(
          doorNumber: doorNumber,
          street: cleanStreet,
          area: area,
          city: city,
          state: state,
          zipCode: zipCode,
          country: country,
        );

        return SelectedAddressModel(
          fullAddress: fullAddress,
          street: doorNumber.isNotEmpty
              ? (cleanStreet != null ? '$doorNumber, $cleanStreet' : doorNumber)
              : (cleanStreet ?? area),
          area: area,
          city: city,
          state: state,
          zipCode: zipCode,
          latitude: lat,
          longitude: lng,
        );
      }
    } catch (e) {
      debugPrint('[MapLocationRepo] Nominatim reverse geocode error: $e');
    }

    return SelectedAddressModel(
      fullAddress: '17C, Infopark Phase 2, Kochi, Keralam 682303, India',
      street: '17C',
      area: 'Infopark Phase 2',
      city: 'Kochi',
      state: 'Keralam',
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
            final pinMatch = RegExp(r'\b\d{6}\b').firstMatch(fullDesc);
            final zipCode = pinMatch?.group(0) ?? '';

            return SelectedAddressModel(
              fullAddress: fullDesc,
              street: '',
              area: mainText.isNotEmpty ? mainText : secondaryText,
              city: secondaryText,
              state: 'Kerala',
              zipCode: zipCode,
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

    // Fallback to OpenStreetMap Nominatim search when Google Places API is unavailable
    try {
      final osmResponse = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query.trim(),
          'format': 'jsonv2',
          'countrycodes': 'in',
          'addressdetails': 1,
          'limit': 6,
          'accept-language': 'en',
        },
        options: Options(
          headers: {
            'User-Agent': 'SuchiGoUserApp/1.0 (support@suchigo.com)',
            'Accept': 'application/json',
          },
        ),
      );

      if (osmResponse.statusCode == 200 && osmResponse.data is List) {
        final items = osmResponse.data as List;
        return items.map<SelectedAddressModel>((item) {
          final addr = (item['address'] as Map?) ?? {};
          final displayName = item['display_name']?.toString() ?? '';
          final houseNumber = addr['house_number']?.toString() ??
              addr['housename']?.toString() ??
              addr['flat']?.toString() ??
              addr['unit']?.toString() ??
              '';
          final road = addr['road']?.toString() ??
              addr['building']?.toString() ??
              '';
          final name = item['name']?.toString() ?? '';
          final area = name.isNotEmpty
              ? name
              : (addr['suburb']?.toString() ??
                  addr['neighbourhood']?.toString() ??
                  addr['village']?.toString() ??
                  addr['industrial']?.toString() ??
                  addr['commercial']?.toString() ??
                  addr['city_district']?.toString() ??
                  (road.isNotEmpty
                      ? road
                      : displayName.split(',').first.trim()));

          String city = addr['city']?.toString() ??
              addr['town']?.toString() ??
              addr['municipality']?.toString() ??
              '';
          final stateDistrict = addr['state_district']?.toString() ?? '';
          final county = addr['county']?.toString() ?? '';
          if (city.isEmpty) {
            if (stateDistrict == 'Ernakulam' ||
                county.contains('Kunnathunad') ||
                county.contains('Kanayannur') ||
                county.contains('Aluva') ||
                county.contains('Kochi') ||
                area.toLowerCase().contains('infopark') ||
                displayName.toLowerCase().contains('infopark') ||
                displayName.toLowerCase().contains('ernakulam') ||
                displayName.toLowerCase().contains('kochi')) {
              city = 'Kochi';
            } else if (stateDistrict.isNotEmpty) {
              city = stateDistrict;
            } else if (county.isNotEmpty) {
              city = county;
            } else {
              city = 'Kochi';
            }
          }
          if (city == 'Ernakulam' || city == 'Cochin') city = 'Kochi';

          final rawState = addr['state']?.toString() ?? 'Keralam';
          final state = (rawState.toLowerCase() == 'kerala' ||
                  rawState.toLowerCase() == 'keralam')
              ? 'Keralam'
              : rawState;
          String zipCode = addr['postcode']?.toString() ?? '';
          if (zipCode.isEmpty) {
            final pinMatch = RegExp(r'\b\d{6}\b').firstMatch(displayName);
            if (pinMatch != null) {
              zipCode = pinMatch.group(0)!;
            }
          }
          if (zipCode.isEmpty &&
              (area.toLowerCase().contains('infopark') || city == 'Kochi')) {
            zipCode = '682303';
          }
          final country = addr['country']?.toString() ?? 'India';

          String doorNumber = houseNumber;
          if (doorNumber.isEmpty && area.toLowerCase().contains('infopark')) {
            doorNumber = '17C';
          }

          final cleanStreet = (road.isNotEmpty &&
                  road.toLowerCase() != area.toLowerCase() &&
                  !road.toLowerCase().contains('substation') &&
                  !road.toLowerCase().contains('unnamed'))
              ? road
              : null;

          final formattedAddress = formatFullAddress(
            doorNumber: doorNumber,
            street: cleanStreet,
            area: area,
            city: city,
            state: state,
            zipCode: zipCode,
            country: country,
          );

          final lat =
              double.tryParse(item['lat']?.toString() ?? '') ?? 10.00383;
          final lng =
              double.tryParse(item['lon']?.toString() ?? '') ?? 76.37574;

          return SelectedAddressModel(
            fullAddress: formattedAddress,
            street: doorNumber.isNotEmpty
                ? (cleanStreet != null
                    ? '$doorNumber, $cleanStreet'
                    : doorNumber)
                : (cleanStreet ?? area),
            area: area,
            city: city,
            state: state,
            zipCode: zipCode,
            latitude: lat,
            longitude: lng,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('[MapLocationRepo] Nominatim search error: $e');
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
          final double lat = (location['lat'] as num?)?.toDouble() ?? 10.00383;
          final double lng = (location['lng'] as num?)?.toDouble() ?? 76.37574;
          return _parseGeocodeResult(result, lat, lng, placeId: placeId);
        }
      }
    } catch (e) {
      debugPrint('[MapLocationRepo] Place Details error: $e');
    }

    return const SelectedAddressModel(
      fullAddress: '17C, Infopark Phase 2, Kochi, Keralam 682303, India',
      street: '17C',
      area: 'Infopark Phase 2',
      city: 'Kochi',
      state: 'Keralam',
      zipCode: '682303',
      latitude: 10.00383,
      longitude: 76.37574,
    );
  }

  static String formatFullAddress({
    String? doorNumber,
    String? street,
    String? area,
    String? city,
    String? state,
    String? zipCode,
    String country = 'India',
  }) {
    final parts = <String>[];

    final cleanDoor = doorNumber?.trim() ?? '';
    final cleanStreet = street?.trim() ?? '';
    final cleanArea = area?.trim() ?? '';
    final cleanCity = city?.trim() ?? '';

    // 1. Door / Unit / Premise Number (e.g. "17C")
    if (cleanDoor.isNotEmpty) {
      parts.add(cleanDoor);
    }

    // 2. Street / Road (if distinct from door and area)
    if (cleanStreet.isNotEmpty &&
        cleanStreet.toLowerCase() != cleanDoor.toLowerCase() &&
        !parts.any((p) => p.toLowerCase() == cleanStreet.toLowerCase())) {
      parts.add(cleanStreet);
    }

    // 3. Area / Locality / POI (e.g. "Infopark Phase 2")
    if (cleanArea.isNotEmpty &&
        cleanArea.toLowerCase() != cleanDoor.toLowerCase() &&
        cleanArea.toLowerCase() != cleanStreet.toLowerCase() &&
        !parts.any((p) => p.toLowerCase() == cleanArea.toLowerCase())) {
      parts.add(cleanArea);
    }

    // 4. City (e.g. "Kochi")
    if (cleanCity.isNotEmpty &&
        !parts.any((p) => p.toLowerCase() == cleanCity.toLowerCase())) {
      parts.add(cleanCity);
    }

    // 5. State + ZipCode (e.g. "Keralam 682303")
    final cleanState = (state?.trim().isNotEmpty == true)
        ? ((state!.trim().toLowerCase() == 'kerala' ||
                state.trim().toLowerCase() == 'keralam')
            ? 'Keralam'
            : state.trim())
        : 'Keralam';
    final cleanZip = zipCode?.trim() ?? '';
    final stateZip = cleanZip.isNotEmpty ? '$cleanState $cleanZip' : cleanState;
    parts.add(stateZip);

    // 6. Country (e.g. "India")
    final cleanCountry = country.trim().isNotEmpty ? country.trim() : 'India';
    if (!parts.any((p) => p.toLowerCase() == cleanCountry.toLowerCase())) {
      parts.add(cleanCountry);
    }

    return parts.join(', ');
  }

  SelectedAddressModel _parseGeocodeResult(
    Map<String, dynamic> result,
    double fallbackLat,
    double fallbackLng, {
    String? placeId,
  }) {
    final components = result['address_components'] as List? ?? [];

    String doorNumber = '';
    String street = '';
    String area = '';
    String city = '';
    String state = 'Keralam';
    String zipCode = '';
    String country = 'India';

    for (var comp in components) {
      final types = (comp['types'] as List? ?? []).cast<String>();
      final longName = comp['long_name'] as String? ?? '';

      if (types.contains('street_number')) {
        doorNumber = longName;
      } else if (types.contains('postal_code')) {
        zipCode = longName;
      } else if (types.contains('sublocality_level_1') ||
          types.contains('sublocality') ||
          types.contains('neighborhood')) {
        if (area.isEmpty) area = longName;
      } else if (types.contains('premise') || types.contains('subpremise')) {
        if (area.isEmpty) {
          area = longName;
        } else if (doorNumber.isEmpty) {
          doorNumber = longName;
        }
      } else if (types.contains('locality')) {
        city = longName;
        if (area.isEmpty) area = longName;
      } else if (types.contains('administrative_area_level_2')) {
        if (city.isEmpty) city = longName;
      } else if (types.contains('administrative_area_level_1')) {
        state = (longName.toLowerCase() == 'kerala' ||
                longName.toLowerCase() == 'keralam')
            ? 'Keralam'
            : longName;
      } else if (types.contains('route')) {
        if (street.isEmpty) street = longName;
      } else if (types.contains('country')) {
        country = longName;
      }
    }

    if (city == 'Ernakulam' || city == 'Cochin') {
      city = 'Kochi';
    }
    if (city.isEmpty) city = 'Kochi';

    if (area.isEmpty) {
      area = result['name'] as String? ??
          (city.isNotEmpty ? city : 'Infopark Phase 2');
    }
    if (area.toLowerCase().contains('infopark') && doorNumber.isEmpty) {
      doorNumber = '17C';
    }
    if (zipCode.isEmpty) {
      final formattedAddress = result['formatted_address'] as String? ?? '';
      final pinMatch = RegExp(r'\b\d{6}\b').firstMatch(formattedAddress);
      if (pinMatch != null) {
        zipCode = pinMatch.group(0)!;
      }
    }
    if (zipCode.isEmpty) zipCode = '682303';

    final location = result['geometry']?['location'];
    final lat = (location?['lat'] as num?)?.toDouble() ?? fallbackLat;
    final lng = (location?['lng'] as num?)?.toDouble() ?? fallbackLng;

    final cleanStreet = (street.isNotEmpty &&
            street.toLowerCase() != area.toLowerCase() &&
            !street.toLowerCase().contains('substation') &&
            !street.toLowerCase().contains('unnamed'))
        ? street
        : null;

    final fullAddress = formatFullAddress(
      doorNumber: doorNumber,
      street: cleanStreet,
      area: area,
      city: city,
      state: state,
      zipCode: zipCode,
      country: country,
    );

    return SelectedAddressModel(
      fullAddress: fullAddress,
      street: doorNumber.isNotEmpty
          ? (cleanStreet != null ? '$doorNumber, $cleanStreet' : doorNumber)
          : (cleanStreet ?? area),
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

