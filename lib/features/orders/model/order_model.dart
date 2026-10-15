import 'package:intl/intl.dart';

enum OrderStatus {
  all,
  completed,
  pending,
  cancelled,
}

class OrderModel {
  final int id;
  final String wasteTypeName;
  final String? subWasteTypeName;
  final String fullName;
  final String email;
  final String contactNumber;
  final String street;
  final String city;
  final String zipCode;
  final String state;
  final String district;
  final String localbody;
  final String wardName;
  final String? landmark;
  final String pickupDate;
  final String pickupTimeSlot;
  final String rawStatus;
  final String itemsDescription;
  final String? vehicleName;
  final String? vehicleNumber;
  final String createdAt;
  final int? user;
  final int? wasteType;
  final int? subWasteType;

  const OrderModel({
    required this.id,
    this.wasteTypeName = '',
    this.subWasteTypeName,
    this.fullName = '',
    this.email = '',
    this.contactNumber = '',
    this.street = '',
    this.city = '',
    this.zipCode = '',
    this.state = '',
    this.district = '',
    this.localbody = '',
    this.wardName = '',
    this.landmark,
    this.pickupDate = '',
    this.pickupTimeSlot = '',
    this.rawStatus = 'pending',
    this.itemsDescription = '',
    this.vehicleName,
    this.vehicleNumber,
    this.createdAt = '',
    this.user,
    this.wasteType,
    this.subWasteType,
  });

  String get code => 'WC-$id';

  int get count => 1;

  double get weightKg => 0.0;

  String get displayTitle {
    if (wasteTypeName.isNotEmpty) return wasteTypeName;
    if (subWasteTypeName != null && subWasteTypeName!.isNotEmpty) {
      return subWasteTypeName!;
    }
    switch (wasteType) {
      case 1:
        return 'Organic Waste';
      case 2:
        return 'Hazardous Waste';
      case 3:
        return 'Recyclable Waste';
      case 4:
        return 'E-Waste';
      case 5:
        return 'General Waste';
      default:
        return itemsDescription.isNotEmpty ? itemsDescription : 'Waste Pickup';
    }
  }

  String get dateString {
    if (pickupDate.isNotEmpty) {
      try {
        final dt = DateTime.parse(pickupDate);
        return DateFormat('d MMM yyyy').format(dt);
      } catch (_) {
        return pickupDate;
      }
    }
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt);
        return DateFormat('d MMM yyyy').format(dt);
      } catch (_) {
        return createdAt.split('T').first;
      }
    }
    return '';
  }

  String get address {
    final List<String> parts = [];
    if (street.isNotEmpty) {
      parts.add(street);
    }
    if (city.isNotEmpty && !street.contains(city)) {
      parts.add(city);
    }
    if (district.isNotEmpty &&
        !street.contains(district) &&
        district.toLowerCase() != city.toLowerCase()) {
      parts.add(district);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'No address provided';
  }

  OrderStatus get orderStatus {
    final s = rawStatus.toLowerCase().trim();
    if (s.contains('complete') || s.contains('done') || s.contains('collected')) {
      return OrderStatus.completed;
    }
    if (s.contains('cancel') || s.contains('reject')) {
      return OrderStatus.cancelled;
    }
    return OrderStatus.pending;
  }

  OrderStatus get status => orderStatus;

  String get statusLabel {
    switch (orderStatus) {
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.pending:
        return rawStatus.isNotEmpty ? rawStatus.toLowerCase() : 'pending';
      case OrderStatus.cancelled:
        return 'cancelled';
      case OrderStatus.all:
        return 'all';
    }
  }

  factory OrderModel.fromJson(Map<dynamic, dynamic> json) => OrderModel(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        wasteTypeName: json['waste_type_name']?.toString() ?? '',
        subWasteTypeName: json['sub_waste_type_name']?.toString(),
        fullName: json['full_name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        contactNumber: json['contact_number']?.toString() ?? '',
        street: json['street']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        zipCode: json['zip_code']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        district: json['district']?.toString() ?? '',
        localbody: json['localbody']?.toString() ?? '',
        wardName: json['ward_name']?.toString() ?? '',
        landmark: json['landmark']?.toString(),
        pickupDate: json['pickup_date']?.toString() ?? '',
        pickupTimeSlot: json['pickup_time_slot']?.toString() ?? '',
        rawStatus: json['status']?.toString() ?? 'pending',
        itemsDescription: json['items_description']?.toString() ?? '',
        vehicleName: json['vehicle_name']?.toString(),
        vehicleNumber: json['vehicle_number']?.toString(),
        createdAt: json['created_at']?.toString() ?? '',
        user: int.tryParse(json['user']?.toString() ?? ''),
        wasteType: int.tryParse(json['waste_type']?.toString() ?? ''),
        subWasteType: int.tryParse(json['sub_waste_type']?.toString() ?? ''),
      );
}
