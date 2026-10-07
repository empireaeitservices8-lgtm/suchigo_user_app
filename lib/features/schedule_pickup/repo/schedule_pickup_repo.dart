import '../model/schedule_pickup_model.dart';

abstract class SchedulePickupRepository {
  Future<List<String>> getStates();
  Future<List<String>> getDistricts(String state);
  Future<List<String>> getLocalBodies(String district);
  Future<List<String>> getWards(String localBody);
  Future<bool> submitPickupSchedule(SchedulePickupRequestModel request);
}

class SchedulePickupRepositoryImpl implements SchedulePickupRepository {
  @override
  Future<List<String>> getStates() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['Kerala', 'Tamil Nadu', 'Karnataka', 'Maharashtra'];
  }

  @override
  Future<List<String>> getDistricts(String state) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      'Ernakulam',
      'Thrissur',
      'Thiruvananthapuram',
      'Kollam',
      'Pathanamthitta',
      'Alappuzha',
      'Kottayam',
      'Idukki',
      'Palakkad',
      'Malappuram',
      'Kozhikode',
      'Wayanad',
      'Kannur',
      'Kasaragod',
    ];
  }

  @override
  Future<List<String>> getLocalBodies(String district) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      'Alangad Panchayat',
      'Aluva Municipality',
      'Angamaly Municipality',
      'Cheranalloor Grama Panchayat',
      'Choornikkara Gram Panchayat',
      'Edathala Gram Panchayat',
      'Kalamassery Municipality',
      'Kochi Municipal Corporation',
      'Maradu Municipality',
      'Paravur Municipality',
      'Tripunithura Municipality',
      'Vazhakulam Grama Panchayat',
    ];
  }

  @override
  Future<List<String>> getWards(String localBody) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      'Neericode West',
      'Neericode East',
      'Panchayat Head Quarters',
      'Koduvazhanga North',
      'Iravipuram',
      'Kottapuram',
      'Karumalloor',
      'Manakkappady',
      'Kongorpilly South',
      'Kongorpilly North',
      'Panayikkulam West',
      'Panayikkulam East',
    ];
  }

  @override
  Future<bool> submitPickupSchedule(SchedulePickupRequestModel request) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return true;
  }
}
