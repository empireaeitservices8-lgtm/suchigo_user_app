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
  final TextEditingController contactNumberController = TextEditingController();
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
    fullNameController.addListener(_onFormUpdated);
    contactNumberController.addListener(_onFormUpdated);
    pickupAddressController.addListener(_onFormUpdated);
    zipCodeController.addListener(_onFormUpdated);
    bagsCountController.addListener(_onFormUpdated);
    loadUserProfile();
    _repository.getDisposalRates().then((_) {
      if (_jurisdiction.localBodyId != null &&
          _jurisdiction.ratePerKg == null) {
        fetchAndApplyDisposalRate(_jurisdiction.localBodyId!);
      }
    });
  }

  void _onFormUpdated() {
    notifyListeners();
  }

  PickupResponseModel? _createdPickup;

  List<CalendarDateModel> _calendarDates = [];
  bool _isLoadingCalendarDates = false;
  int _calendarRequestId = 0;

  JurisdictionModel get jurisdiction => _jurisdiction;
  DateTime? get pickupDate => _pickupDate;
  PickupResponseModel? get createdPickup => _createdPickup;
  ProfileResponseModel? get userProfile => _userProfile;

  /// Returns true only when all required booking fields are filled.
  bool get isFormComplete {
    final hasDistrict = _jurisdiction.district != 'Not Selected' &&
        _jurisdiction.district.trim().isNotEmpty;
    final hasLocalBody = _jurisdiction.localBody != 'Not Selected' &&
        _jurisdiction.localBody.trim().isNotEmpty;
    final hasFullName = fullNameController.text.trim().isNotEmpty;
    final hasContactNumber = contactNumberController.text.trim().isNotEmpty;
    final hasAddress = pickupAddressController.text.trim().isNotEmpty;
    final hasZipCode = zipCodeController.text.trim().isNotEmpty;
    final hasPickupDate = _pickupDate != null;
    final hasBagsCount = bagsCountController.text.trim().isNotEmpty;

    return hasDistrict &&
        hasLocalBody &&
        hasFullName &&
        hasContactNumber &&
        hasAddress &&
        hasZipCode &&
        hasPickupDate &&
        hasBagsCount;
  }

  /// All dates returned by the calendar-dates API for the selected local body.
  List<CalendarDateModel> get calendarDates => _calendarDates;
  bool get isLoadingCalendarDates => _isLoadingCalendarDates;

  /// Weekdays allowed by the calendar-dates API for the selected local body.
  Set<int> get _allowedWeekdays =>
      _calendarDates.map((c) => c.weekday).toSet();

  CalendarDateModel? _findCalendarEntry(DateTime target) {
    for (final c in _calendarDates) {
      if (c.date.year == target.year &&
          c.date.month == target.month &&
          c.date.day == target.day) {
        return c;
      }
    }
    return null;
  }

  /// Selectable pickup dates from today up to 1 year ahead, matching the
  /// API's `day_of_week` while respecting `is_active` and `is_full`.
  List<DateTime> get upcomingPickupDates {
    if (_calendarDates.isEmpty) return const [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = DateTime(today.year + 1, today.month, today.day);
    final result = <DateTime>[];
    for (var day = today;
        !day.isAfter(maxDate);
        day = DateTime(day.year, day.month, day.day + 1)) {
      if (isPickupDateAvailable(day)) {
        result.add(day);
      }
    }
    return result;
  }

  bool isPickupDateAvailable(DateTime date) {
    if (_calendarDates.isEmpty) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final maxDate = DateTime(today.year + 1, today.month, today.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target.isBefore(today) || target.isAfter(maxDate)) return false;

    final exactEntry = _findCalendarEntry(target);
    if (exactEntry != null) {
      return exactEntry.isSelectable;
    }
    return _allowedWeekdays.contains(target.weekday);
  }

  Future<void> loadCalendarDates(int localBodyId) async {
    final requestId = ++_calendarRequestId;
    _isLoadingCalendarDates = true;
    _calendarDates = [];
    notifyListeners();
    final dates = await _repository.getCalendarDates(localBodyId);
    if (requestId != _calendarRequestId) return; // stale response
    _calendarDates = dates;
    _isLoadingCalendarDates = false;
    if (_pickupDate != null && !isPickupDateAvailable(_pickupDate!)) {
      _pickupDate = null;
    }
    if (_pickupDate == null && upcomingPickupDates.isNotEmpty) {
      _pickupDate = upcomingPickupDates.first;
    }
    notifyListeners();
  }

  void _clearCalendarDates() {
    _calendarRequestId++;
    _calendarDates = [];
    _isLoadingCalendarDates = false;
    _pickupDate = null;
  }

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
              '${profile.user!.firstName!} ${profile.user?.lastName ?? ''}'
                  .trim();
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
    _clearCalendarDates();
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
      ratePerKg: 0.00,
    );
    _clearCalendarDates();
    notifyListeners();
    if (localBodyId != null && localBodyId > 0) {
      fetchAndApplyDisposalRate(localBodyId);
      loadCalendarDates(localBodyId);
    }
  }

  Future<void> fetchAndApplyDisposalRate(int localBodyId) async {
    final rate = await _repository.getDisposalRateForLocalBody(localBodyId);
    if (rate != null && rate > 0) {
      setRatePerKg(rate);
    } else {
      setRatePerKg(0.00);
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

  String? validateForm() {
    if (_jurisdiction.district == 'Not Selected' ||
        _jurisdiction.district.trim().isEmpty) {
      return 'Please select a District';
    }
    if (_jurisdiction.localBody == 'Not Selected' ||
        _jurisdiction.localBody.trim().isEmpty) {
      return 'Please select a Local Body';
    }
    if (_jurisdiction.wardNameAndNumber == 'Not Selected' ||
        _jurisdiction.wardNameAndNumber.trim().isEmpty ||
        _jurisdiction.wardId == null) {
      return 'Please select Ward Name & Number';
    }
    if (fullNameController.text.trim().isEmpty) {
      return 'Please enter your Full Name';
    }
    if (contactNumberController.text.trim().isEmpty) {
      return 'Please enter your Contact Number';
    }
    if (pickupAddressController.text.trim().isEmpty) {
      return 'Please enter Pickup Address';
    }
    final selectedState = stateController.text.trim().isNotEmpty
        ? stateController.text.trim()
        : _jurisdiction.state.trim();
    if (selectedState.isEmpty) {
      return 'Please enter or select State';
    }
    final zip = zipCodeController.text.trim();
    if (zip.isEmpty) {
      return 'Please enter Zip / Postal Code';
    }
    if (zip.length < 5) {
      return 'Please enter a valid Zip / Postal Code';
    }
    if (_pickupDate == null) {
      return 'Please select a Pickup Date';
    }
    return null;
  }

  Future<bool> submit({Function(String error)? onError}) async {
    if (_jurisdiction.district == 'Not Selected') {
      onError?.call('Please select a district');
      return false;
    }
    if (_jurisdiction.localBody == 'Not Selected') {
      onError?.call('Please select a local body');
      return false;
    }
    if (contactNumberController.text.trim().isEmpty) {
      onError?.call('Please enter your contact number');
      return false;
    }

    isLoading = true;
    notifyListeners();
    try {
      // Auto-fallback pickup date if not chosen
      if (_pickupDate == null && upcomingPickupDates.isNotEmpty) {
        _pickupDate = upcomingPickupDates.first;
      }
      _pickupDate ??= DateTime.now().add(const Duration(days: 1));

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
    fullNameController.removeListener(_onFormUpdated);
    contactNumberController.removeListener(_onFormUpdated);
    pickupAddressController.removeListener(_onFormUpdated);
    zipCodeController.removeListener(_onFormUpdated);
    bagsCountController.removeListener(_onFormUpdated);
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
