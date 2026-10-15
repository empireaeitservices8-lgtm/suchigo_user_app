import 'package:suchigo_user_app/helpers/sp_helper.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import 'package:suchigo_user_app/utils/sp_keys.dart' as sp_keys;
import '../model/profile_model.dart';
import '../repo/profile_repo.dart';

class ProfileViewModel extends ViewModel {
  final ProfileRepository _repository;
  ProfileResponseModel? _profile;
  String? _errorMessage;

  ProfileViewModel({
    ProfileRepository? repository,
    ProfileResponseModel? initialProfile,
  })  : _repository = repository ?? ProfileRepositoryImpl(),
        _profile = initialProfile {
    if (_profile == null) {
      loadProfile();
    }
  }

  ProfileResponseModel? get profile => _profile;
  String? get errorMessage => _errorMessage;

  String get userName {
    if (_profile?.fullName != null &&
        _profile!.fullName.isNotEmpty &&
        _profile!.fullName != 'User') {
      return _profile!.fullName.toUpperCase();
    }
    return '';
  }

  String get phoneNumber =>
      _profile?.phoneNumber ?? _profile?.displayPhone ?? '';
  String get address => _profile?.address ?? '';
  String get email => _profile?.email ?? '';
  String? get profilePicture => _profile?.profilePicture;

  Future<void> loadProfile() async {
    isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile(
        onError: (error) {
          _errorMessage = error.message;
        },
      );
      if (_profile != null) {
        if (_profile!.fullName.isNotEmpty) {
          await SpHelper.saveString(sp_keys.keyUserName, _profile!.fullName);
        }
        if (_profile!.phoneNumber != null &&
            _profile!.phoneNumber!.isNotEmpty) {
          await SpHelper.saveString(
              sp_keys.keyUseMobile, _profile!.phoneNumber!);
        }
        if (_profile!.email.isNotEmpty) {
          await SpHelper.saveString(sp_keys.keyEmail, _profile!.email);
        }
      }
    } catch (e) {
      _errorMessage ??= 'Failed to load profile';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
