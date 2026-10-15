import 'package:intl/intl.dart';

class PickupVehicleTrackingModel {
  final int pickupId;
  final String status;
  final String? vehicleName;
  final String? vehicleNumber;
  final String pickupDate;
  final String pickupTimeSlot;
  final String fullName;
  final String contactNumber;
  final String address;
  final String? landmark;

  const PickupVehicleTrackingModel({
    required this.pickupId,
    this.status = 'pending',
    this.vehicleName,
    this.vehicleNumber,
    this.pickupDate = '',
    this.pickupTimeSlot = '',
    this.fullName = '',
    this.contactNumber = '',
    this.address = '',
    this.landmark,
  });

  String get formattedDate {
    if (pickupDate.isEmpty) return 'Pending Schedule';
    try {
      final dt = DateTime.parse(pickupDate);
      return DateFormat('EEE, d MMM yyyy').format(dt);
    } catch (_) {
      return pickupDate;
    }
  }

  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'collected':
        return 'Collected';
      case 'on_the_way':
      case 'in_transit':
      case 'dispatched':
        return 'On The Way';
      case 'assigned':
        return 'Vehicle Assigned';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pickup Scheduled';
    }
  }

  int get currentStep {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'collected':
        return 3;
      case 'on_the_way':
      case 'in_transit':
      case 'dispatched':
        return 2;
      case 'assigned':
        return 1;
      case 'cancelled':
        return 0;
      case 'pending':
      default:
        return vehicleName != null && vehicleName!.isNotEmpty ? 1 : 0;
    }
  }

  factory PickupVehicleTrackingModel.fromJson(Map<dynamic, dynamic> json) {
    return PickupVehicleTrackingModel(
      pickupId: int.tryParse(json['pickup_id']?.toString() ?? '') ??
          int.tryParse(json['id']?.toString() ?? '') ??
          0,
      status: json['status']?.toString() ?? 'pending',
      vehicleName: json['vehicle_name']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString(),
      pickupDate: json['pickup_date']?.toString() ?? '',
      pickupTimeSlot: json['pickup_time_slot']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
    );
  }
}
