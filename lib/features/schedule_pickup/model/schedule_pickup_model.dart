class JurisdictionModel {
  final String state;
  final String district;
  final String localBody;
  final String wardNameAndNumber;
  final double? ratePerKg;

  const JurisdictionModel({
    this.state = 'Kerala',
    this.district = 'Not Selected',
    this.localBody = 'Not Selected',
    this.wardNameAndNumber = 'Not Selected',
    this.ratePerKg,
  });

  JurisdictionModel copyWith({
    String? state,
    String? district,
    String? localBody,
    String? wardNameAndNumber,
    double? ratePerKg,
  }) {
    return JurisdictionModel(
      state: state ?? this.state,
      district: district ?? this.district,
      localBody: localBody ?? this.localBody,
      wardNameAndNumber: wardNameAndNumber ?? this.wardNameAndNumber,
      ratePerKg: ratePerKg ?? this.ratePerKg,
    );
  }
}

class SchedulePickupRequestModel {
  final JurisdictionModel jurisdiction;
  final String fullName;
  final String contactNumber;
  final String email;
  final String pickupAddress;
  final String zipCode;
  final DateTime? pickupDate;
  final int numberOfBags;
  final String secondaryNumber;
  final String landmark;

  const SchedulePickupRequestModel({
    required this.jurisdiction,
    required this.fullName,
    required this.contactNumber,
    this.email = '',
    required this.pickupAddress,
    required this.zipCode,
    this.pickupDate,
    this.numberOfBags = 1,
    this.secondaryNumber = '',
    this.landmark = '',
  });
}
