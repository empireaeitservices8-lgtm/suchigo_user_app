import 'package:flutter/material.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/auth_model.dart';
import '../repo/auth_repo.dart';

class CompleteProfileViewModel extends ViewModel {
  final AuthRepository _repository;
  final String phoneNumber;
  final String otp;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  Gender _selectedGender = Gender.female;
  UserProfileModel? _createdProfile;
  String? _errorMessage;

  CompleteProfileViewModel({
    required this.phoneNumber,
    required this.otp,
    AuthRepository? repository,
  }) : _repository = repository ?? AuthRepositoryImpl() {
    firstNameController.addListener(_onFieldChanged);
    lastNameController.addListener(_onFieldChanged);
  }

  Gender get selectedGender => _selectedGender;
  UserProfileModel? get createdProfile => _createdProfile;
  String? get errorMessage => _errorMessage;

  String get formattedPhoneNumber {
    final clean = phoneNumber.replaceAll('+', '').replaceAll('91', '');
    return '+91$clean';
  }

  bool get isFormValid =>
      firstNameController.text.trim().isNotEmpty &&
      lastNameController.text.trim().isNotEmpty;

  void setGender(Gender gender) {
    if (_selectedGender != gender) {
      _selectedGender = gender;
      notifyListeners();
    }
  }

  void _onFieldChanged() {
    notifyListeners();
  }

  Future<bool> createAccount() async {
    if (!isFormValid) return false;
    _errorMessage = null;
    isLoading = true;
    try {
      _createdProfile = await _repository.completeProfile(
        CompleteProfileRequestModel(
          phoneNumber: phoneNumber,
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          otp: otp,
          gender: _selectedGender,
        ),
        onError: (error) => _errorMessage = error.message,
      );
      return true;
    } catch (e) {
      _errorMessage ??= 'Registration failed. Please try again.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }
}
