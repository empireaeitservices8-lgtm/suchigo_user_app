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
  final String? collectorName;
  final String? collectorPhone;
  final int? orderNumber;
  final int? orderId;
  final String wasteTypeName;
  final double? weight;
  final double? amount;
  final double? bagCharge;

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
    this.collectorName,
    this.collectorPhone,
    this.orderNumber,
    this.orderId,
    this.wasteTypeName = '',
    this.weight,
    this.amount,
    this.bagCharge,
  });

  bool get hasCollector =>
      collectorName != null && collectorName!.trim().isNotEmpty;

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
    switch (status.toLowerCase().replaceAll('-', '_').trim()) {
      case 'completed':
      case 'collected':
      case 'done':
        return 'Collected';
      case 'travelling':
      case 'traveling':
      case 'travel':
        return 'Travelling';
      case 'in_transit':
      case 'on_the_way':
      case 'dispatched':
      case 'moving':
        return 'In Transit';
      case 'assigned':
        return 'Vehicle Assigned';
      case 'cancelled':
      case 'rejected':
        return 'Cancelled';
      case 'pending':
      case 'scheduled':
      default:
        return 'Pickup Scheduled';
    }
  }

  int get currentStep {
    switch (status.toLowerCase().replaceAll('-', '_').trim()) {
      case 'completed':
      case 'collected':
      case 'done':
        return 3;
      case 'travelling':
      case 'traveling':
      case 'travel':
      case 'in_transit':
      case 'on_the_way':
      case 'dispatched':
      case 'moving':
        return 2;
      case 'assigned':
        return 1;
      case 'cancelled':
        return -1;
      case 'pending':
      case 'scheduled':
      default:
        return (vehicleName != null && vehicleName!.trim().isNotEmpty) ? 1 : 0;
    }
  }

  factory PickupVehicleTrackingModel.fromJson(Map<dynamic, dynamic> json) {
    return PickupVehicleTrackingModel(
      pickupId: int.tryParse(json['pickup_id']?.toString() ?? '') ??
          int.tryParse(json['id']?.toString() ?? '') ??
          0,
      status: json['status']?.toString() ??
          json['pickup_status']?.toString() ??
          json['order_status']?.toString() ??
          'pending',
      vehicleName: json['vehicle_name']?.toString() ??
          json['vehicle']?.toString() ??
          json['vehicle_type']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString() ??
          json['vehicle_no']?.toString() ??
          json['reg_number']?.toString(),
      pickupDate: json['pickup_date']?.toString() ?? '',
      pickupTimeSlot: json['pickup_time_slot']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      contactNumber: json['contact_number']?.toString() ?? '',
      address: json['address']?.toString() ?? json['street']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
      collectorName: json['collector_name']?.toString() ??
          json['driver_name']?.toString() ??
          (json['collector'] is Map
              ? json['collector']['name']?.toString()
              : (json['collector'] is String ? json['collector'] : null)),
      collectorPhone: json['collector_phone']?.toString() ??
          json['driver_phone']?.toString() ??
          (json['collector'] is Map
              ? json['collector']['phone']?.toString()
              : null),
      orderNumber: int.tryParse(json['order_number']?.toString() ?? ''),
      orderId: int.tryParse(json['order_id']?.toString() ?? ''),
      wasteTypeName: json['waste_type_name']?.toString() ?? '',
      weight: double.tryParse(json['weight']?.toString() ?? ''),
      amount: double.tryParse(json['amount']?.toString() ?? ''),
      bagCharge: double.tryParse(json['bag_charge']?.toString() ?? ''),
    );
  }
}
