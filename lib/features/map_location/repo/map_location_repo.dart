import '../model/map_location_model.dart';

abstract class MapLocationRepository {
  Future<SelectedAddressModel> getAddressFromCoordinates(
      double lat, double lng);
  Future<List<SelectedAddressModel>> searchPlaces(String query);
}

class MapLocationRepositoryImpl implements MapLocationRepository {
  @override
  Future<SelectedAddressModel> getAddressFromCoordinates(
      double lat, double lng) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const SelectedAddressModel(
      fullAddress: 'Door No. 12/450, Alangad Road, Near Juma Masjid, Alangad, Ernakulam, Kerala - 683511',
      street: 'Door No. 12/450, Alangad Road',
      area: 'Near Juma Masjid, Alangad',
      city: 'Ernakulam',
      state: 'Kerala',
      zipCode: '683511',
      latitude: 10.1132,
      longitude: 76.2894,
    );
  }

  @override
  Future<List<SelectedAddressModel>> searchPlaces(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      SelectedAddressModel(
        fullAddress: 'Alangad, Ernakulam, Kerala - 683511',
        street: 'Alangad Main Rd',
        area: 'Alangad',
        city: 'Ernakulam',
        state: 'Kerala',
        zipCode: '683511',
        latitude: 10.1132,
        longitude: 76.2894,
      ),
      SelectedAddressModel(
        fullAddress: 'Aluva Municipal Town, Ernakulam, Kerala - 683101',
        street: 'Bank Junction',
        area: 'Aluva',
        city: 'Ernakulam',
        state: 'Kerala',
        zipCode: '683101',
        latitude: 10.1076,
        longitude: 76.3516,
      ),
    ];
  }
}
