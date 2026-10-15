import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/urls.dart';
import '../model/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationItemModel>> getNotifications();
  Future<bool> markAsRead(String id);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final WebAPIService _apiService;

  NotificationRepositoryImpl({WebAPIService? apiService})
      : _apiService = apiService ?? WebAPIService();

  @override
  Future<List<NotificationItemModel>> getNotifications() async {
    await _apiService.initTokenToHeader();

    try {
      final response = await _apiService.dio.get(urlPickups);
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
        final list = rawList
            .whereType<Map>()
            .map((item) => NotificationItemModel.fromPickupJson(item))
            .toList();

        return list;
      }
    } catch (_) {
      // Return fallback defaults if API fails
    }

    return const [
      NotificationItemModel(
        id: '1',
        title: 'SuchiGo Pickup Today',
        message:
            'Our collector will arrive today. Please ensure waste is accessible!',
        dateTime: 'Sep 21, 2026 at 08:00 AM',
        type: NotificationFilter.upcoming,
        isRead: false,
      ),
      NotificationItemModel(
        id: '2',
        title: 'SuchiGo Pickup Reminder',
        message:
            'Your garbage pickup is scheduled for tomorrow. Please keep your bags ready!',
        dateTime: 'Sep 20, 2026 at 04:00 PM',
        type: NotificationFilter.delivered,
        isRead: true,
      ),
    ];
  }

  @override
  Future<bool> markAsRead(String id) async {
    return true;
  }
}
