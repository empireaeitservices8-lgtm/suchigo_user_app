import 'package:suchigo_user_app/helpers/sp_helper.dart';
import 'package:suchigo_user_app/models/app_error_model.dart';
import 'package:suchigo_user_app/services/push_notification_service.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/sp_keys.dart' as sp_keys;
import 'package:suchigo_user_app/utils/urls.dart';

import '../model/auth_model.dart';

abstract class AuthRepository {
  Future<SendOTPResponseModel> sendOTP(
    AuthRequestModel request, {
    Function(AppError error)? onError,
  });
  Future<LoginResponseModel> login(
    LoginRequestModel request, {
    Function(AppError error)? onError,
  });
  Future<OTPVerificationModel> verifyOTP(
    VerifyOTPRequestModel request, {
    Function(AppError error)? onError,
  });
  Future<SendOTPResponseModel> resendOTP(
    AuthRequestModel request, {
    Function(AppError error)? onError,
  });
  Future<UserProfileModel> completeProfile(
    CompleteProfileRequestModel request, {
    Function(AppError error)? onError,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final WebAPIService _apiService;

  AuthRepositoryImpl({WebAPIService? apiService})
      : _apiService = apiService ?? WebAPIService();

  @override
  Future<SendOTPResponseModel> sendOTP(
    AuthRequestModel request, {
    Function(AppError error)? onError,
  }) async {
    return _apiService.executeAPI<SendOTPResponseModel>(
      methodToCall: _apiService.dio.post(
        urlSendOTP,
        data: request.toSendOTPJson(),
      ),
      converter: SendOTPResponseModel.fromJson,
      onError: onError,
    );
  }

  @override
  Future<LoginResponseModel> login(
    LoginRequestModel request, {
    Function(AppError error)? onError,
  }) async {
    final response = await _apiService.executeAPI<LoginResponseModel>(
      methodToCall: _apiService.dio.post(
        urlLogin,
        data: request.toJson(),
      ),
      converter: LoginResponseModel.fromJson,
      onError: onError,
    );
    if (response.hasToken) {
      await _saveLoginSession(response);
    }
    return response;
  }

  @override
  Future<OTPVerificationModel> verifyOTP(
    VerifyOTPRequestModel request, {
    Function(AppError error)? onError,
  }) async {
    final response = await _apiService.executeAPI<OTPVerificationModel>(
      methodToCall: _apiService.dio.post(
        urlVerifyOTP,
        data: request.toJson(),
      ),
      converter: OTPVerificationModel.fromJson,
      onError: onError,
    );
    if (response.token != null && response.token!.isNotEmpty) {
      await _saveVerifySession(response);
      if (response.userId == null) {
        try {
          await _apiService.initTokenToHeader();
          final profRes = await _apiService.dio.get(urlProfile);
          if (profRes.data is Map) {
            final data = profRes.data as Map;
            final rootMap = data['data'] is Map
                ? data['data'] as Map
                : (data['profile'] is Map ? data['profile'] as Map : data);
            final userObj = rootMap['user'];
            final userMap = userObj is Map ? userObj as Map : null;
            final pid = rootMap['user_id']?.toString() ??
                rootMap['userId']?.toString() ??
                userMap?['id']?.toString() ??
                userMap?['user_id']?.toString() ??
                (userObj != null && userObj is! Map ? userObj.toString() : null) ??
                rootMap['id']?.toString();
            if (pid != null && pid.isNotEmpty) {
              await SpHelper.saveString(sp_keys.keyUserId, pid);
            }
          }
        } catch (_) {}
      }
    }
    return response;
  }

  Future<void> _saveVerifySession(OTPVerificationModel model) async {
    if (model.token != null && model.token!.isNotEmpty) {
      await SpHelper.saveString(sp_keys.keyToken, model.token!);
    }
    if (model.phoneNumber != null && model.phoneNumber!.isNotEmpty) {
      await SpHelper.saveString(sp_keys.keyUseMobile, model.phoneNumber!);
    }
    if (model.userId != null) {
      await SpHelper.saveString(sp_keys.keyUserId, model.userId.toString());
    }
    PushNotificationService.instance.syncDeviceToken();
  }

  @override
  Future<SendOTPResponseModel> resendOTP(
    AuthRequestModel request, {
    Function(AppError error)? onError,
  }) =>
      sendOTP(request, onError: onError);

  @override
  Future<UserProfileModel> completeProfile(
    CompleteProfileRequestModel request, {
    Function(AppError error)? onError,
  }) async {
    final profile = await _apiService.executeAPI<UserProfileModel>(
      methodToCall: _apiService.dio.post(
        urlRegister,
        data: request.toJson(),
      ),
      converter: UserProfileModel.fromJson,
      onError: onError,
    );
    await _saveSession(profile);
    return profile;
  }

  Future<void> _saveSession(UserProfileModel profile) async {
    await SpHelper.saveString(sp_keys.keyToken, profile.token);
    if (profile.userId != null) {
      await SpHelper.saveString(sp_keys.keyUserId, profile.userId.toString());
    }
    await SpHelper.saveString(sp_keys.keyEmail, profile.email);
    await SpHelper.saveString(sp_keys.keyUseMobile, profile.phoneNumber);
    await SpHelper.saveString(sp_keys.keyUserName, profile.fullName);
    PushNotificationService.instance.syncDeviceToken();
  }

  Future<void> _saveLoginSession(LoginResponseModel model) async {
    if (model.token != null && model.token!.isNotEmpty) {
      await SpHelper.saveString(sp_keys.keyToken, model.token!);
    }
    if (model.userId != null) {
      await SpHelper.saveString(sp_keys.keyUserId, model.userId.toString());
    }
    if (model.email != null && model.email!.isNotEmpty) {
      await SpHelper.saveString(sp_keys.keyEmail, model.email!);
    }
    if (model.phoneNumber != null && model.phoneNumber!.isNotEmpty) {
      await SpHelper.saveString(sp_keys.keyUseMobile, model.phoneNumber!);
    }
    if (model.fullName.isNotEmpty) {
      await SpHelper.saveString(sp_keys.keyUserName, model.fullName);
    }
    PushNotificationService.instance.syncDeviceToken();
  }
}
