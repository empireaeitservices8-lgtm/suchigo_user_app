import 'package:flutter/material.dart';
import 'package:suchigo_user_app/helpers/sp_helper.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import 'package:suchigo_user_app/utils/sp_keys.dart' as sp_keys;
import '../../profile/model/profile_model.dart';
import '../model/schedule_pickup_model.dart';
import '../repo/schedule_pickup_repo.dart';

class SchedulePickupViewModel extends ViewModel {
  final SchedulePickupRepository _repository;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController contactNumberController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pickupAddressController = TextEditingController();
  final TextEditingController stateController =
      TextEditingController(text: 'Kerala');
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
  ProfileResponseModel? _userProfile;

  SchedulePickupViewModel({SchedulePickupRepository? repository})
      : _repository = repository ?? SchedulePickupRepositoryImpl() {
    loadUserProfile();
    _repository.getDisposalRates().then((_) {
      if (_jurisdiction.localBodyId != null && _jurisdiction.ratePerKg == null) {
        fetchAndApplyDisposalRate(_jurisdiction.localBodyId!);
      }
    });
  }

  PickupResponseModel? _createdPickup;

  JurisdictionModel get jurisdiction => _jurisdiction;
  DateTime? get pickupDate => _pickupDate;
  PickupResponseModel? get createdPickup => _createdPickup;
  ProfileResponseModel? get userProfile => _userProfile;

  Future<void> loadUserProfile() async {
    try {
      final cachedName = await SpHelper.getString(sp_keys.keyUserName);
      var cachedPhone = await SpHelper.getString(sp_keys.keyUseMobile) ??
          await SpHelper.getString('KEY_PHONE_NUMBER');
      final cachedEmail = await SpHelper.getString(sp_keys.keyEmail) ??
          await SpHelper.getString('KEY_USER_EMAIL');

      if (cachedPhone != null && cachedPhone.contains('7592964952')) {
        cachedPhone = null;
      }

      if (cachedName != null &&
          cachedName.isNotEmpty &&
          cachedName.toLowerCase() != 'user') {
        if (fullNameController.text.trim().isEmpty) {
          fullNameController.text = cachedName;
        }
      }
      if (cachedPhone != null && cachedPhone.isNotEmpty) {
        if (contactNumberController.text.trim().isEmpty) {
          contactNumberController.text = cachedPhone;
        }
      } else if (contactNumberController.text.trim().isEmpty) {
        contactNumberController.text = '+917306929058';
      }
      if (cachedEmail != null && cachedEmail.isNotEmpty) {
        if (emailController.text.trim().isEmpty) {
          emailController.text = cachedEmail;
        }
      }
      notifyListeners();
    } catch (_) {}

    try {
      final profile = await _repository.getUserProfile();
      if (profile != null) {
        _userProfile = profile;

        final name = profile.fullName;
        if (name.isNotEmpty && name.toLowerCase() != 'user') {
          fullNameController.text = name;
          await SpHelper.saveString(sp_keys.keyUserName, name);
        } else if (profile.user?.firstName != null &&
            profile.user!.firstName!.isNotEmpty) {
          final fullName =
              '${profile.user!.firstName!} ${profile.user?.lastName ?? ''}'.trim();
          fullNameController.text = fullName;
          await SpHelper.saveString(sp_keys.keyUserName, fullName);
        }

        final phone = profile.displayPhone;
        final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
        final isValidPhone =
            digits.length >= 10 && !digits.contains('7592964952');

        if (isValidPhone) {
          contactNumberController.text = phone;
          await SpHelper.saveString(sp_keys.keyUseMobile, phone);
        } else if (contactNumberController.text.trim().isEmpty ||
            contactNumberController.text.contains('7592964952')) {
          final savedMobile = await SpHelper.getString(sp_keys.keyUseMobile);
          if (savedMobile != null &&
              savedMobile.isNotEmpty &&
              !savedMobile.contains('7592964952')) {
            contactNumberController.text = savedMobile;
          } else {
            contactNumberController.text = '+917306929058';
          }
        }

        if (profile.email.isNotEmpty) {
          emailController.text = profile.email;
          await SpHelper.saveString(sp_keys.keyEmail, profile.email);
        }

        if (profile.address != null &&
            profile.address!.isNotEmpty &&
            pickupAddressController.text.trim().isEmpty) {
          pickupAddressController.text = profile.address!;
        }

        notifyListeners();
      }
    } catch (_) {}
  }

  void setState(String state) {
    _jurisdiction = _jurisdiction.copyWith(state: state);
    stateController.text = state;
    notifyListeners();
  }

  void setDistrict(String district, {int? districtId}) {
    _jurisdiction = _jurisdiction.copyWith(
      district: district,
      districtId: districtId,
      clearDistrictId: districtId == null,
      localBody: 'Not Selected',
      clearLocalBodyId: true,
      wardNameAndNumber: 'Not Selected',
      clearWardId: true,
      clearWardNumber: true,
      clearRatePerKg: true,
    );
    notifyListeners();
  }

  void setLocalBody(String localBody, {int? localBodyId}) {
    _jurisdiction = _jurisdiction.copyWith(
      localBody: localBody,
      localBodyId: localBodyId,
      clearLocalBodyId: localBodyId == null,
      wardNameAndNumber: 'Not Selected',
      clearWardId: true,
      clearWardNumber: true,
      ratePerKg: 40.00,
    );
    notifyListeners();
    if (localBodyId != null && localBodyId > 0) {
      fetchAndApplyDisposalRate(localBodyId);
    }
  }

  Future<void> fetchAndApplyDisposalRate(int localBodyId) async {
    final rate = await _repository.getDisposalRateForLocalBody(localBodyId);
    if (rate != null && rate > 0) {
      setRatePerKg(rate);
    } else {
      setRatePerKg(40.00);
    }
  }

  void setWard(String ward, {int? wardId, int? wardNumber}) {
    _jurisdiction = _jurisdiction.copyWith(
      wardNameAndNumber: ward,
      wardId: wardId,
      clearWardId: wardId == null,
      wardNumber: wardNumber,
      clearWardNumber: wardNumber == null,
    );
    notifyListeners();
  }

  void setPickupDate(DateTime date) {
    _pickupDate = date;
    notifyListeners();
  }

  void setRatePerKg(double? rate) {
    _jurisdiction = _jurisdiction.copyWith(
      ratePerKg: rate,
      clearRatePerKg: rate == null,
    );
    notifyListeners();
  }

  Future<bool> submit({Function(String error)? onError}) async {
    isLoading = true;
    notifyListeners();
    try {
      final selectedState = stateController.text.trim().isNotEmpty
          ? stateController.text.trim()
          : _jurisdiction.state;
      final request = SchedulePickupRequestModel(
        jurisdiction: _jurisdiction.copyWith(state: selectedState),
        fullName: fullNameController.text.trim(),
        contactNumber: contactNumberController.text.trim(),
        email: emailController.text.trim(),
        pickupAddress: pickupAddressController.text.trim(),
        state: selectedState,
        zipCode: zipCodeController.text.trim(),
        pickupDate: _pickupDate,
        numberOfBags: int.tryParse(bagsCountController.text) ?? 1,
        secondaryNumber: secondaryNumberController.text.trim(),
        landmark: landmarkController.text.trim(),
      );
      _createdPickup = await _repository.submitPickupSchedule(
        request,
        onError: (err) => onError?.call(err.message),
      );
      return _createdPickup != null;
    } catch (e) {
      onError?.call('An unexpected error occurred: $e');
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
    stateController.dispose();
    zipCodeController.dispose();
    bagsCountController.dispose();
    secondaryNumberController.dispose();
    landmarkController.dispose();
    super.dispose();
  }
}
