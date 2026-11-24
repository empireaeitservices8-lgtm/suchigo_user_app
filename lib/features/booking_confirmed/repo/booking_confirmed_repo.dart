import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/urls.dart';
import '../model/booking_confirmed_model.dart';

abstract class BookingConfirmedRepository {
  Future<BookingConfirmedModel> getBookingDetails({String? bookingId});
}

class BookingConfirmedRepositoryImpl implements BookingConfirmedRepository {
  final WebAPIService _apiService;

  BookingConfirmedRepositoryImpl({WebAPIService? apiService})
      : _apiService = apiService ?? WebAPIService();

  @override
  Future<BookingConfirmedModel> getBookingDetails({String? bookingId}) async {
    developer.log(
      'getBookingDetails called with bookingId: $bookingId',
      name: 'BookingConfirmedRepo',
    );
    debugPrint(
      '[BookingConfirmedRepo] getBookingDetails called with bookingId: $bookingId',
    );

    final cleanId = bookingId?.replaceAll(RegExp(r'[^0-9]'), '');
    await _apiService.initTokenToHeader();

    // 1. If cleanId is provided, attempt direct fetch from /api/pickups/<cleanId>/
    if (cleanId != null && cleanId.isNotEmpty) {
      try {
        final directUrl = '${urlPickups}$cleanId/';
        developer.log(
          'Calling API direct pickup URL: $directUrl',
          name: 'BookingConfirmedRepo',
        );
        debugPrint(
          '[BookingConfirmedRepo] Calling API direct pickup URL: $directUrl',
        );

        final response = await _apiService.dio.get(directUrl);
        developer.log(
          'API response from $directUrl: ${response.statusCode}',
          name: 'BookingConfirmedRepo',
        );
        debugPrint(
          '[BookingConfirmedRepo] API response status from direct URL: ${response.statusCode}',
        );

        if (response.statusCode == 200 && response.data is Map) {
          final model =
              BookingConfirmedModel.fromJson(response.data as Map);
          developer.log(
            'Parsed direct BookingConfirmedModel: orderId=${model.orderId}, pickupId=${model.pickupId}, bookingId=${model.bookingId}',
            name: 'BookingConfirmedRepo',
          );
          debugPrint(
            '[BookingConfirmedRepo] Parsed direct model: orderId=${model.orderId}, pickupId=${model.pickupId}',
          );
          return model;
        }
      } catch (e) {
        developer.log(
          'Direct fetch for $cleanId failed ($e), falling back to list endpoint',
          name: 'BookingConfirmedRepo',
        );
        debugPrint(
          '[BookingConfirmedRepo] Direct fetch for $cleanId failed: $e. Falling back to list endpoint.',
        );
      }
    }

    // 2. Fetch list from urlPickups (GET https://suchigoapis.pythonanywhere.com/api/pickups/)
    try {
      developer.log(
        'Calling API pickups list: $urlPickups',
        name: 'BookingConfirmedRepo',
      );
      debugPrint(
        '[BookingConfirmedRepo] Calling API pickups list: $urlPickups',
      );

      final response = await _apiService.dio.get(urlPickups);
      developer.log(
        'API pickups list response status: ${response.statusCode}',
        name: 'BookingConfirmedRepo',
      );
      debugPrint(
        '[BookingConfirmedRepo] Pickups list response status: ${response.statusCode}',
      );

      List items = [];
      if (response.data is List) {
        items = response.data as List;
      } else if (response.data is Map) {
        final map = response.data as Map;
        if (map['data'] is List) {
          items = map['data'] as List;
        } else if (map['results'] is List) {
          items = map['results'] as List;
        }
      }

      developer.log(
        'Fetched ${items.length} pickups from API list',
        name: 'BookingConfirmedRepo',
      );
      debugPrint(
        '[BookingConfirmedRepo] Fetched ${items.length} pickups from API list',
      );

      if (items.isNotEmpty) {
        Map? matched;
        if (cleanId != null && cleanId.isNotEmpty) {
          for (final item in items) {
            if (item is Map) {
              final id = item['id']?.toString();
              final orderId = item['order_id']?.toString();
              final orderNumber = item['order_number']?.toString();
              if (id == cleanId ||
                  orderId == cleanId ||
                  orderNumber == cleanId) {
                matched = item;
                break;
              }
            }
          }
        }

        // If no match found or cleanId not provided, take the latest pickup (first in list)
        matched ??= items.firstWhere(
          (element) => element is Map,
          orElse: () => null,
        ) as Map?;

        if (matched != null) {
          final model = BookingConfirmedModel.fromJson(matched);
          developer.log(
            'Matched BookingConfirmedModel: orderId=${model.orderId}, pickupId=${model.pickupId}, bookingId=${model.bookingId}',
            name: 'BookingConfirmedRepo',
          );
          debugPrint(
            '[BookingConfirmedRepo] Matched: orderId=${model.orderId}, pickupId=${model.pickupId}',
          );
          return model;
        }
      }
    } catch (e) {
      developer.log(
        'Error fetching pickups list: $e',
        name: 'BookingConfirmedRepo',
      );
      debugPrint('[BookingConfirmedRepo] Error fetching pickups list: $e');
    }

    // 3. Fallback if network or match fails
    return BookingConfirmedModel(
      bookingId: bookingId != null && bookingId.isNotEmpty
          ? bookingId.replaceAll('#', '').trim()
          : (cleanId ?? ''),
      orderId: cleanId,
      pickupId: int.tryParse(cleanId ?? ''),
    );
  }
}
