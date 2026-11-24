import 'package:intl/intl.dart';

class BookingConfirmedModel {
  final String bookingId;
  final String? orderId;
  final int? pickupId;
  final String status;
  final String wasteType;
  final String collectionDate;
  final String estWeight;
  final String contactName;
  final String contactPhone;
  final String pickupAddress;
  final String co2Saved;
  final String recycledPercent;
  final String treesEquiv;
  final String standardRate;

  const BookingConfirmedModel({
    this.bookingId = '',
    this.orderId,
    this.pickupId,
    this.status = 'Confirmed',
    this.wasteType = '1',
    this.collectionDate = '',
    this.estWeight = '0.0 kg',
    this.contactName = '',
    this.contactPhone = '',
    this.pickupAddress = '',
    this.co2Saved = '0.0kg',
    this.recycledPercent = '0%',
    this.treesEquiv = '',
    this.standardRate = '',
  });

  BookingConfirmedModel copyWith({
    String? bookingId,
    String? orderId,
    int? pickupId,
    String? status,
    String? wasteType,
    String? collectionDate,
    String? estWeight,
    String? contactName,
    String? contactPhone,
    String? pickupAddress,
    String? co2Saved,
    String? recycledPercent,
    String? treesEquiv,
    String? standardRate,
  }) {
    return BookingConfirmedModel(
      bookingId: bookingId ?? this.bookingId,
      orderId: orderId ?? this.orderId,
      pickupId: pickupId ?? this.pickupId,
      status: status ?? this.status,
      wasteType: wasteType ?? this.wasteType,
      collectionDate: collectionDate ?? this.collectionDate,
      estWeight: estWeight ?? this.estWeight,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      co2Saved: co2Saved ?? this.co2Saved,
      recycledPercent: recycledPercent ?? this.recycledPercent,
      treesEquiv: treesEquiv ?? this.treesEquiv,
      standardRate: standardRate ?? this.standardRate,
    );
  }

  factory BookingConfirmedModel.fromJson(Map<dynamic, dynamic> json) {
    final rawOrderId = json['order_id'] ?? json['order_number'];
    final orderIdStr = rawOrderId?.toString();
    final pickupId = int.tryParse(json['id']?.toString() ?? '');

    final displayId = orderIdStr != null && orderIdStr.isNotEmpty
        ? orderIdStr.replaceAll('#', '').trim()
        : (pickupId != null ? '$pickupId' : '');

    final rawStatus = json['status']?.toString() ?? 'pending';
    final capitalizedStatus = rawStatus.isNotEmpty
        ? rawStatus[0].toUpperCase() + rawStatus.substring(1)
        : 'Confirmed';

    final dateStr = json['pickup_date']?.toString() ?? '';
    String formattedDate = dateStr;
    if (dateStr.isNotEmpty) {
      try {
        final parsed = DateTime.parse(dateStr);
        formattedDate = DateFormat('EEEE, d MMM yyyy').format(parsed);
      } catch (_) {
        formattedDate = dateStr;
      }
    }

    final street = json['street']?.toString() ?? '';
    final district = json['district']?.toString() ?? '';
    final zip = json['zip_code']?.toString() ?? '';
    String address = street;
    if (street.isNotEmpty &&
        !street.contains('India') &&
        (!street.contains(zip) || zip.isEmpty)) {
      if (district.isNotEmpty && zip.isNotEmpty) {
        address = '$street,\n$district – $zip';
      }
    }

    final weightVal = json['weight'];
    final estWeight = weightVal != null ? '$weightVal kg' : '2.5 kg';

    return BookingConfirmedModel(
      bookingId: displayId,
      orderId: orderIdStr,
      pickupId: pickupId,
      status: capitalizedStatus,
      wasteType: () {
        final wName = json['waste_type_name']?.toString() ??
            json['waste_type']?.toString() ??
            '';
        final wId = json['waste_type']?.toString();
        if (wId == '4' || wName.toLowerCase().contains('sanitary')) {
          return 'Sanitary Waste';
        }
        if (wName.isNotEmpty && wName != '1') {
          return wName;
        }
        return 'Sanitary Waste';
      }(),
      collectionDate: formattedDate,
      estWeight: estWeight,
      contactName: json['full_name']?.toString() ?? '',
      contactPhone: json['contact_number']?.toString() ?? '',
      pickupAddress: address,
      co2Saved: '0.0 kg',
      recycledPercent: '0%',
      treesEquiv: '0.0',
      standardRate: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'order_id': orderId,
      'pickup_id': pickupId,
      'status': status,
      'waste_type': wasteType,
      'collection_date': collectionDate,
      'est_weight': estWeight,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'pickup_address': pickupAddress,
      'co2_saved': co2Saved,
      'recycled_percent': recycledPercent,
      'trees_equiv': treesEquiv,
      'standard_rate': standardRate,
    };
  }
}
