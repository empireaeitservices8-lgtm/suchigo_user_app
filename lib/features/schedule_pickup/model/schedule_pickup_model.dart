import 'package:intl/intl.dart';

class JurisdictionModel {
  final String state;
  final String district;
  final int? districtId;
  final String localBody;
  final int? localBodyId;
  final String wardNameAndNumber;
  final int? wardId;
  final int? wardNumber;
  final double? ratePerKg;

  const JurisdictionModel({
    this.state = 'Kerala',
    this.district = 'Not Selected',
    this.districtId,
    this.localBody = 'Not Selected',
    this.localBodyId,
    this.wardNameAndNumber = 'Not Selected',
    this.wardId,
    this.wardNumber,
    this.ratePerKg,
  });

  JurisdictionModel copyWith({
    String? state,
    String? district,
    int? districtId,
    bool clearDistrictId = false,
    String? localBody,
    int? localBodyId,
    bool clearLocalBodyId = false,
    String? wardNameAndNumber,
    int? wardId,
    bool clearWardId = false,
    int? wardNumber,
    bool clearWardNumber = false,
    double? ratePerKg,
    bool clearRatePerKg = false,
  }) {
    return JurisdictionModel(
      state: state ?? this.state,
      district: district ?? this.district,
      districtId: clearDistrictId ? null : (districtId ?? this.districtId),
      localBody: localBody ?? this.localBody,
      localBodyId: clearLocalBodyId ? null : (localBodyId ?? this.localBodyId),
      wardNameAndNumber: wardNameAndNumber ?? this.wardNameAndNumber,
      wardId: clearWardId ? null : (wardId ?? this.wardId),
      wardNumber: clearWardNumber ? null : (wardNumber ?? this.wardNumber),
      ratePerKg: clearRatePerKg ? null : (ratePerKg ?? this.ratePerKg),
    );
  }
}

class SchedulePickupRequestModel {
  final JurisdictionModel jurisdiction;
  final String fullName;
  final String contactNumber;
  final String email;
  final String pickupAddress;
  final String state;
  final String zipCode;
  final DateTime? pickupDate;
  final int numberOfBags;
  final String secondaryNumber;
  final String landmark;
  final int wasteType;
  final int? subWasteType;

  const SchedulePickupRequestModel({
    required this.jurisdiction,
    required this.fullName,
    required this.contactNumber,
    this.email = '',
    required this.pickupAddress,
    this.state = 'Kerala',
    required this.zipCode,
    this.pickupDate,
    this.numberOfBags = 1,
    this.secondaryNumber = '',
    this.landmark = '',
    this.wasteType = 1,
    this.subWasteType,
  });

  Map<String, dynamic> toJson() {
    final cleanWard = jurisdiction.wardNameAndNumber.contains(' - ')
        ? jurisdiction.wardNameAndNumber.split(' - ').last.trim()
        : (jurisdiction.wardNameAndNumber != 'Not Selected'
            ? jurisdiction.wardNameAndNumber
            : 'Neericode West');

    final cleanLocalBody = jurisdiction.localBody != 'Not Selected'
        ? jurisdiction.localBody
        : 'Alangad Panchayat';

    final cleanDistrict = jurisdiction.district != 'Not Selected'
        ? jurisdiction.district
        : 'Ernakulam';

    final cleanDate = pickupDate != null
        ? DateFormat('yyyy-MM-dd').format(pickupDate!)
        : DateFormat('yyyy-MM-dd')
            .format(DateTime.now().add(const Duration(days: 2)));

    final cleanContact =
        contactNumber.isNotEmpty ? contactNumber : '+917306929058';
    final cleanEmail = email.isNotEmpty
        ? email
        : '${cleanContact.replaceAll('+', '').replaceAll(' ', '')}@suchigo.com';

    final cleanState = state.trim().isNotEmpty
        ? state.trim()
        : (jurisdiction.state.isNotEmpty ? jurisdiction.state : 'Kerala');

    return {
      'full_name': fullName.isNotEmpty ? fullName : 'tesdt',
      'email': cleanEmail,
      'contact_number': cleanContact,
      'street': pickupAddress.isNotEmpty
          ? pickupAddress
          : '9F, Kakkanad, Keralam, 682303, India',
      'city': cleanDistrict,
      'zip_code': zipCode.isNotEmpty ? zipCode : '682303',
      'state': cleanState,
      'district': cleanDistrict,
      'localbody': cleanLocalBody,
      'ward_name': cleanWard,
      'pickup_date': cleanDate,
      'pickup_time_slot': '9:00 AM – 12:00 PM',
      'items_description': 'General household waste',
      'waste_type': wasteType,
      'sub_waste_type': subWasteType,
      'landmark': landmark.isNotEmpty ? landmark : null,
    };
  }
}

class PickupResponseModel {
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
  final String localBody;
  final String wardName;
  final String? landmark;
  final String pickupDate;
  final String pickupTimeSlot;
  final String status;
  final String itemsDescription;
  final String? vehicleName;
  final String? vehicleNumber;
  final String? createdAt;
  final int? user;
  final int? wasteType;
  final int? subWasteType;

  const PickupResponseModel({
    required this.id,
    this.wasteTypeName = '',
    this.subWasteTypeName,
    required this.fullName,
    required this.email,
    required this.contactNumber,
    required this.street,
    required this.city,
    required this.zipCode,
    required this.state,
    required this.district,
    required this.localBody,
    required this.wardName,
    this.landmark,
    required this.pickupDate,
    required this.pickupTimeSlot,
    this.status = 'pending',
    this.itemsDescription = '',
    this.vehicleName,
    this.vehicleNumber,
    this.createdAt,
    this.user,
    this.wasteType,
    this.subWasteType,
  });

  factory PickupResponseModel.fromJson(Map<dynamic, dynamic> json) {
    return PickupResponseModel(
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
      localBody: json['localbody']?.toString() ?? '',
      wardName: json['ward_name']?.toString() ?? '',
      landmark: json['landmark']?.toString(),
      pickupDate: json['pickup_date']?.toString() ?? '',
      pickupTimeSlot: json['pickup_time_slot']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      itemsDescription: json['items_description']?.toString() ?? '',
      vehicleName: json['vehicle_name']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString(),
      createdAt: json['created_at']?.toString(),
      user: int.tryParse(json['user']?.toString() ?? ''),
      wasteType: int.tryParse(json['waste_type']?.toString() ?? ''),
      subWasteType: int.tryParse(json['sub_waste_type']?.toString() ?? ''),
    );
  }
}

class StateModel {
  final int id;
  final String name;

  const StateModel({
    required this.id,
    required this.name,
  });

  factory StateModel.fromJson(Map<dynamic, dynamic> json) {
    return StateModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class DistrictModel {
  final int id;
  final String name;
  final int? stateId;

  const DistrictModel({
    required this.id,
    required this.name,
    this.stateId,
  });

  factory DistrictModel.fromJson(Map<dynamic, dynamic> json) {
    return DistrictModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      stateId: int.tryParse(
        json['state']?.toString() ?? json['state_id']?.toString() ?? '',
      ),
    );
  }
}

class LocalBodyModel {
  final int id;
  final String name;
  final String? localBodyType;
  final int? districtId;

  const LocalBodyModel({
    required this.id,
    required this.name,
    this.localBodyType,
    this.districtId,
  });

  factory LocalBodyModel.fromJson(Map<dynamic, dynamic> json) {
    return LocalBodyModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ??
          json['local_body_name']?.toString() ??
          '',
      localBodyType: json['localbody_type']?.toString() ??
          json['local_body_type']?.toString(),
      districtId: int.tryParse(
        json['district']?.toString() ?? json['district_id']?.toString() ?? '',
      ),
    );
  }
}

class WardModel {
  final int id;
  final int wardNumber;
  final String wardName;
  final int? localBodyId;

  const WardModel({
    required this.id,
    required this.wardNumber,
    required this.wardName,
    this.localBodyId,
  });

  String get displayName {
    if (wardNumber > 0 && wardName.isNotEmpty) {
      return 'Ward $wardNumber - $wardName';
    }
    return wardName;
  }

  factory WardModel.fromJson(Map<dynamic, dynamic> json) {
    return WardModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      wardNumber: int.tryParse(json['ward_number']?.toString() ?? '') ?? 0,
      wardName: json['ward_name']?.toString() ?? '',
      localBodyId: int.tryParse(
        json['local_body']?.toString() ?? json['local_body_id']?.toString() ?? '',
      ),
    );
  }
}

class DisposalRateModel {
  final int id;
  final int localBodyId;
  final double ratePerKg;

  const DisposalRateModel({
    required this.id,
    required this.localBodyId,
    required this.ratePerKg,
  });

  factory DisposalRateModel.fromJson(Map<dynamic, dynamic> json) {
    return DisposalRateModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      localBodyId: int.tryParse(
            json['local_body']?.toString() ??
                json['local_body_id']?.toString() ??
                '',
          ) ??
          0,
      ratePerKg:
          double.tryParse(json['rate_per_kg']?.toString() ?? '') ?? 0.0,
    );
  }
}

