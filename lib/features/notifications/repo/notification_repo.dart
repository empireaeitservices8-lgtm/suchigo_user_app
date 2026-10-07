import '../model/notification_model.dart';

abstract class NotificationRepository {
  Future<List<NotificationItemModel>> getNotifications();
  Future<bool> markAsRead(String id);
}

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<NotificationItemModel>> getNotifications() async {
    // Return mock notifications as shown in screenshot
    return const [
      NotificationItemModel(
        id: '1',
        title: 'SuchiGo Pickup Today',
        message:
            'Our collector will arrive today. Please ensure waste is accessible!',
        dateTime: 'Sep 21, 2026 at 08:00 AM',
        type: NotificationFilter.delivered,
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
