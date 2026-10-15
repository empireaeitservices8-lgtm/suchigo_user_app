class SelectedAddressModel {
  final String fullAddress;
  final String street;
  final String area;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final String? placeId;

  const SelectedAddressModel({
    required this.fullAddress,
    this.street = '',
    required this.area,
    this.city = '',
    this.state = '',
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    this.placeId,
  });

  SelectedAddressModel copyWith({
    String? fullAddress,
    String? street,
    String? area,
    String? city,
    String? state,
    String? zipCode,
    double? latitude,
    double? longitude,
    String? placeId,
  }) {
    return SelectedAddressModel(
      fullAddress: fullAddress ?? this.fullAddress,
      street: street ?? this.street,
      area: area ?? this.area,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId ?? this.placeId,
    );
  }
}
