class SelectedAddressModel {
  final String fullAddress;
  final String street;
  final String area;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;

  const SelectedAddressModel({
    required this.fullAddress,
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
  });
}
