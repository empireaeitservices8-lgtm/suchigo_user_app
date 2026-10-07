enum NotificationFilter {
  all,
  upcoming,
  delivered,
}

class NotificationItemModel {
  final String id;
  final String title;
  final String message;
  final String dateTime;
  final NotificationFilter type;
  final bool isRead;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.isRead = false,
  });
}
