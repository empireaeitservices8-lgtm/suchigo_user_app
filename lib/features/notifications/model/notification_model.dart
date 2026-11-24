import 'package:intl/intl.dart';

enum NotificationFilter {
  all,
  upcoming,
  delivered,
}

class NotificationItemModel {
  final String id;
  final int? pickupId;
  final int? orderId;
  final int? orderNumber;
  final String title;
  final String message;
  final String dateTime;
  final NotificationFilter type;
  final String status;
  final bool isRead;

  const NotificationItemModel({
    required this.id,
    this.pickupId,
    this.orderId,
    this.orderNumber,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.status = 'pending',
    this.isRead = false,
  });

  String get orderCode {
    if (orderNumber != null && orderNumber! > 0) return '$orderNumber';
    if (orderId != null && orderId! > 0) return '$orderId';
    return id;
  }

  NotificationItemModel copyWith({
    String? id,
    int? pickupId,
    int? orderId,
    int? orderNumber,
    String? title,
    String? message,
    String? dateTime,
    NotificationFilter? type,
    String? status,
    bool? isRead,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      pickupId: pickupId ?? this.pickupId,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      title: title ?? this.title,
      message: message ?? this.message,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
    );
  }

  factory NotificationItemModel.fromPickupJson(Map<dynamic, dynamic> json) {
    final id = json['id']?.toString() ?? '0';
    final pickupId = int.tryParse(id);

    int? parsedOrderNumber =
        int.tryParse(json['order_number']?.toString() ?? '');
    int? parsedOrderId = int.tryParse(json['order_id']?.toString() ?? '');

    if (json['order'] is Map) {
      final orderMap = json['order'] as Map;
      parsedOrderId ??= int.tryParse(orderMap['id']?.toString() ?? '');
      parsedOrderNumber ??= int.tryParse(orderMap['order_number']?.toString() ??
          orderMap['code']?.toString() ??
          '');
    } else if (json['order'] is int) {
      parsedOrderId ??= json['order'] as int;
    }

    final orderNumber = parsedOrderNumber;
    final orderId = parsedOrderId ?? orderNumber;
    final String orderDisplayCode = (orderNumber != null && orderNumber > 0)
        ? '$orderNumber'
        : (orderId != null && orderId > 0)
            ? '$orderId'
            : id;

    final wasteTypeName =
        json['waste_type_name']?.toString() ?? 'Waste Pickup';
    final status = json['status']?.toString().toLowerCase() ?? 'pending';
    final pickupDate = json['pickup_date']?.toString() ?? '';
    final timeSlot = json['pickup_time_slot']?.toString() ?? '';
    final ward = json['ward_name']?.toString() ?? '';
    final city = json['city']?.toString() ?? '';
    final createdAt = json['created_at']?.toString() ?? '';

    // Format date for display
    String formattedDate = pickupDate;
    if (pickupDate.isNotEmpty) {
      try {
        final dt = DateTime.parse(pickupDate);
        formattedDate = DateFormat('MMM dd, yyyy').format(dt);
      } catch (_) {}
    } else if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        formattedDate = DateFormat('MMM dd, yyyy').format(dt);
      } catch (_) {}
    }

    String displayTime = timeSlot.isNotEmpty ? ' at $timeSlot' : '';
    String fullDateTime = '$formattedDate$displayTime';

    NotificationFilter filterType;
    String title;
    String message;

    if (status.contains('complete') ||
        status.contains('collect') ||
        status.contains('done')) {
      filterType = NotificationFilter.delivered;
      title = 'Pickup Completed - Order #$orderDisplayCode';
      message =
          'Your $wasteTypeName waste collection at $ward, $city has been completed successfully!';
    } else if (status.contains('cancel')) {
      filterType = NotificationFilter.delivered;
      title = 'Pickup Cancelled - Order #$orderDisplayCode';
      message =
          'Your $wasteTypeName pickup scheduled for $formattedDate was cancelled.';
    } else {
      filterType = NotificationFilter.upcoming;
      title = 'Pickup Scheduled - Order #$orderDisplayCode';
      final loc = ward.isNotEmpty ? ' at $ward, $city' : '';
      message =
          'Your $wasteTypeName collection is scheduled for $formattedDate$displayTime$loc. Please keep your bags ready!';
    }

    return NotificationItemModel(
      id: id,
      pickupId: pickupId,
      orderId: orderId,
      orderNumber: orderNumber,
      title: title,
      message: message,
      dateTime: fullDateTime,
      type: filterType,
      status: status,
      isRead: false,
    );
  }
}
