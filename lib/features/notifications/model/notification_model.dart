import 'package:intl/intl.dart';

enum NotificationFilter {
  all,
  upcoming,
  delivered,
}

class NotificationItemModel {
  final String id;
  final int? pickupId;
  final String title;
  final String message;
  final String dateTime;
  final NotificationFilter type;
  final String status;
  final bool isRead;

  const NotificationItemModel({
    required this.id,
    this.pickupId,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.status = 'pending',
    this.isRead = false,
  });

  factory NotificationItemModel.fromPickupJson(Map<dynamic, dynamic> json) {
    final id = json['id']?.toString() ?? '0';
    final pickupId = int.tryParse(id);
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
      title = 'Pickup Completed - #$id';
      message =
          'Your $wasteTypeName waste collection at $ward, $city has been completed successfully!';
    } else if (status.contains('cancel')) {
      filterType = NotificationFilter.delivered;
      title = 'Pickup Cancelled - #$id';
      message =
          'Your $wasteTypeName pickup scheduled for $formattedDate was cancelled.';
    } else {
      filterType = NotificationFilter.upcoming;
      title = 'Pickup Scheduled - #$id';
      final loc = ward.isNotEmpty ? ' at $ward, $city' : '';
      message =
          'Your $wasteTypeName collection is scheduled for $formattedDate$displayTime$loc. Please keep your bags ready!';
    }

    return NotificationItemModel(
      id: id,
      pickupId: pickupId,
      title: title,
      message: message,
      dateTime: fullDateTime,
      type: filterType,
      status: status,
      isRead: false,
    );
  }
}
