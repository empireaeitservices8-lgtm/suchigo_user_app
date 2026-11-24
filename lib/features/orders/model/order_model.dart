import 'package:intl/intl.dart';

enum OrderStatus {
  all,
  completed,
  pending,
  accepted,
  traveling,
  rescheduled,
  cancelled,
}

class OrderModel {
  final int id;
  final String wasteTypeName;
  final String? subWasteTypeName;
  final double? weight;
  final double? amount;
  final double? bagCharge;
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
  final String? collectorName;
  final String? collectorPhone;
  final int? orderNumber;
  final int? orderId;
  final double? latitude;
  final double? longitude;
  final String createdAt;
  final int? user;
  final int? wasteType;
  final int? subWasteType;

  const OrderModel({
    required this.id,
    this.wasteTypeName = '',
    this.subWasteTypeName,
    this.weight,
    this.amount,
    this.bagCharge,
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
    this.collectorName,
    this.collectorPhone,
    this.orderNumber,
    this.orderId,
    this.latitude,
    this.longitude,
    this.createdAt = '',
    this.user,
    this.wasteType,
    this.subWasteType,
  });

  bool get hasCollector =>
      collectorName != null && collectorName!.trim().isNotEmpty;

  String get code {
    final num = orderNumber ?? orderId ?? id;
    return '$num';
  }

  int get count => 1;

  double get weightKg => weight ?? 0.0;

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
        return 'Sanitary Waste';
      case 5:
        return 'General Waste';
      case 13:
        return 'E-Waste';
      default:
        return itemsDescription.isNotEmpty ? itemsDescription : 'Sanitary Waste';
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
    if (s.contains('complete') ||
        s.contains('done') ||
        s.contains('collected')) {
      return OrderStatus.completed;
    }
    if (s.contains('travel') ||
        s == 'in_transit' ||
        s == 'in-transit' ||
        s == 'transit' ||
        s == 'on_the_way' ||
        s == 'dispatched') {
      return OrderStatus.traveling;
    }
    if (s.contains('accept')) {
      return OrderStatus.accepted;
    }
    if (s.contains('reschedul')) {
      return OrderStatus.rescheduled;
    }
    if (s.contains('cancel') || s.contains('reject')) {
      return OrderStatus.cancelled;
    }
    return OrderStatus.pending;
  }

  OrderStatus get status => orderStatus;

  String get statusLabel {
    final s = rawStatus.toLowerCase().trim();
    if (s.isEmpty) return 'Pending';
    if (s.contains('travel')) {
      return 'Travelling';
    }
    if (s == 'in_transit' ||
        s == 'in-transit' ||
        s == 'transit' ||
        s == 'on_the_way' ||
        s == 'dispatched') {
      return 'In Transit';
    }
    if (s.contains('accept')) return 'Accepted';
    if (s.contains('reschedul')) return 'Rescheduled';
    if (s == 'completed' || s == 'collected') return 'Completed';
    if (s == 'cancelled' || s == 'rejected') return 'Cancelled';
    if (s == 'pending') return 'Pending';
    return s[0].toUpperCase() + s.substring(1);
  }

  factory OrderModel.fromJson(Map<dynamic, dynamic> json) => OrderModel(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        wasteTypeName: json['waste_type_name']?.toString() ?? '',
        subWasteTypeName: json['sub_waste_type_name']?.toString(),
        weight: double.tryParse(json['weight']?.toString() ?? ''),
        amount: double.tryParse(json['amount']?.toString() ?? ''),
        bagCharge: double.tryParse(json['bag_charge']?.toString() ?? ''),
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
        collectorName: json['collector_name']?.toString(),
        collectorPhone: json['collector_phone']?.toString(),
        orderNumber: int.tryParse(json['order_number']?.toString() ?? ''),
        orderId: int.tryParse(json['order_id']?.toString() ?? ''),
        latitude: double.tryParse(json['latitude']?.toString() ?? ''),
        longitude: double.tryParse(json['longitude']?.toString() ?? ''),
        createdAt: json['created_at']?.toString() ?? '',
        user: int.tryParse(json['user']?.toString() ?? ''),
        wasteType: int.tryParse(json['waste_type']?.toString() ?? ''),
        subWasteType: int.tryParse(json['sub_waste_type']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'waste_type_name': wasteTypeName,
        'sub_waste_type_name': subWasteTypeName,
        'weight': weight,
        'amount': amount,
        'bag_charge': bagCharge,
        'full_name': fullName,
        'email': email,
        'contact_number': contactNumber,
        'street': street,
        'city': city,
        'zip_code': zipCode,
        'state': state,
        'district': district,
        'localbody': localbody,
        'ward_name': wardName,
        'landmark': landmark,
        'pickup_date': pickupDate,
        'pickup_time_slot': pickupTimeSlot,
        'status': rawStatus,
        'items_description': itemsDescription,
        'vehicle_name': vehicleName,
        'vehicle_number': vehicleNumber,
        'collector_name': collectorName,
        'collector_phone': collectorPhone,
        'order_number': orderNumber,
        'order_id': orderId,
        'latitude': latitude,
        'longitude': longitude,
        'created_at': createdAt,
        'user': user,
        'waste_type': wasteType,
        'sub_waste_type': subWasteType,
      };
}
