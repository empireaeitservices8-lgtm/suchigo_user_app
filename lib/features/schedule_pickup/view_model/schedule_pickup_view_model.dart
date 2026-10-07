import 'package:flutter/material.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/schedule_pickup_model.dart';
import '../repo/schedule_pickup_repo.dart';

class SchedulePickupViewModel extends ViewModel {
  final SchedulePickupRepository _repository;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController contactNumberController =
      TextEditingController(text: '+917592964952');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pickupAddressController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController bagsCountController =
      TextEditingController(text: '1');
  final TextEditingController secondaryNumberController =
      TextEditingController();
  final TextEditingController landmarkController = TextEditingController();

  JurisdictionModel _jurisdiction = const JurisdictionModel(
    state: 'Kerala',
    district: 'Not Selected',
    localBody: 'Not Selected',
    wardNameAndNumber: 'Not Selected',
  );

  DateTime? _pickupDate;

  SchedulePickupViewModel({SchedulePickupRepository? repository})
      : _repository = repository ?? SchedulePickupRepositoryImpl();

  JurisdictionModel get jurisdiction => _jurisdiction;
  DateTime? get pickupDate => _pickupDate;

  void setState(String state) {
    _jurisdiction = _jurisdiction.copyWith(state: state);
    notifyListeners();
  }

  void setDistrict(String district) {
    _jurisdiction = _jurisdiction.copyWith(district: district);
    notifyListeners();
  }

  void setLocalBody(String localBody) {
    _jurisdiction = _jurisdiction.copyWith(localBody: localBody);
    notifyListeners();
  }

  void setWard(String ward) {
    _jurisdiction = _jurisdiction.copyWith(wardNameAndNumber: ward);
    notifyListeners();
  }

  void setPickupDate(DateTime date) {
    _pickupDate = date;
    notifyListeners();
  }

  void setRatePerKg(double rate) {
    _jurisdiction = _jurisdiction.copyWith(ratePerKg: rate);
    notifyListeners();
  }

  Future<bool> submit() async {
    isLoading = true;
    try {
      final request = SchedulePickupRequestModel(
        jurisdiction: _jurisdiction,
        fullName: fullNameController.text.trim(),
        contactNumber: contactNumberController.text.trim(),
        email: emailController.text.trim(),
        pickupAddress: pickupAddressController.text.trim(),
        zipCode: zipCodeController.text.trim(),
        pickupDate: _pickupDate,
        numberOfBags: int.tryParse(bagsCountController.text) ?? 1,
        secondaryNumber: secondaryNumberController.text.trim(),
        landmark: landmarkController.text.trim(),
      );
      final success = await _repository.submitPickupSchedule(request);
      return success;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    contactNumberController.dispose();
    emailController.dispose();
    pickupAddressController.dispose();
    zipCodeController.dispose();
    bagsCountController.dispose();
    secondaryNumberController.dispose();
    landmarkController.dispose();
    super.dispose();
  }
}
