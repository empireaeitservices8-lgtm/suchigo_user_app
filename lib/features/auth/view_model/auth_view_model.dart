import 'dart:async';
import 'package:flutter/material.dart';
import 'package:suchigo_user_app/models/app_error_model.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/auth_model.dart';
import '../repo/auth_repo.dart';

class AuthViewModel extends ViewModel {
  final AuthRepository _repository;

  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> otpFocusNodes = List.generate(4, (_) => FocusNode());

  AuthMode _mode = AuthMode.register;
  bool _isPhoneValid = false;
  bool _isNotRegistered = false;
  int _resendCountdown = 57;
  Timer? _countdownTimer;
  String? _errorMessage;
  String? _sentOtp;

  AuthViewModel({AuthRepository? repository})
      : _repository = repository ?? AuthRepositoryImpl() {
    phoneController.addListener(_onPhoneChanged);
  }

  AuthMode get mode => _mode;
  bool get isPhoneValid => _isPhoneValid;
  bool get isNotRegistered => _isNotRegistered;
  int get resendCountdown => _resendCountdown;
  String get phoneNumber => phoneController.text.trim();
  String get fullPhoneNumber => '+91${phoneController.text.trim()}';

  /// Last error message from an OTP API call (null if none)
  String? get errorMessage => _errorMessage;

  /// OTP returned by the server (useful for testing)
  String? get sentOtp => _sentOtp;

  AuthRequestModel get _authRequest =>
      AuthRequestModel(phoneNumber: phoneNumber, mode: _mode);

  String get otpCode =>
      otpControllers.map((controller) => controller.text).join();
  bool get isOtpComplete => otpCode.length == 4;

  void toggleMode() {
    _mode =
        _mode == AuthMode.register ? AuthMode.login : AuthMode.register;
    _isNotRegistered = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setMode(AuthMode mode) {
    if (_mode != mode) {
      _mode = mode;
      _isNotRegistered = false;
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _checkIfUnregistered(dynamic errorPayload) {
    if (errorPayload is AppError) {
      final msg = errorPayload.message.toLowerCase();
      if (msg.contains('register') || msg.contains('not found') || msg.contains('no account')) {
        _isNotRegistered = true;
      }
      if (errorPayload.response is Map) {
        final map = errorPayload.response as Map;
        if (map['is_registered'] == false ||
            map['is_registered']?.toString().toLowerCase() == 'false') {
          _isNotRegistered = true;
        }
      }
    }
  }

  void _onPhoneChanged() {
    final text = phoneController.text.trim();
    final isValid = text.length == 10 && RegExp(r'^[0-9]+$').hasMatch(text);
    if (_isPhoneValid != isValid) {
      _isPhoneValid = isValid;
      notifyListeners();
    }
  }

  void startResendTimer() {
    _countdownTimer?.cancel();
    _resendCountdown = 57;
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        _resendCountdown--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<bool> sendOTP() async {
    if (!_isPhoneValid) return false;
    _errorMessage = null;
    _isNotRegistered = false;
    isLoading = true;
    try {
      final response = await _repository.sendOTP(
        _authRequest,
        onError: (error) {
          _errorMessage = error.message;
          _checkIfUnregistered(error);
        },
      );
      if (response.error != null && response.error!.isNotEmpty) {
        _errorMessage = response.error;
        if (!response.isRegistered ||
            response.error!.toLowerCase().contains('register')) {
          _isNotRegistered = true;
        }
        return false;
      }
      if (!response.isRegistered) {
        _isNotRegistered = true;
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'No account found with this phone number. Please register first.';
        return false;
      }
      _sentOtp = response.otp;
      startResendTimer();
      _clearOtpFields();
      return true;
    } catch (e) {
      _errorMessage ??= 'Failed to send OTP. Please try again.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> verifyOTP() async {
    if (!isOtpComplete) return false;
    _errorMessage = null;
    _isNotRegistered = false;
    isLoading = true;
    try {
      if (_mode == AuthMode.login) {
        final result = await _repository.login(
          LoginRequestModel(
            phoneNumber: phoneNumber,
            otp: otpCode,
          ),
          onError: (error) {
            _errorMessage = error.message;
            _checkIfUnregistered(error);
          },
        );
        if (result.error != null && result.error!.isNotEmpty) {
          _errorMessage = result.error;
          if (!result.isRegistered ||
              result.error!.toLowerCase().contains('register')) {
            _isNotRegistered = true;
          }
          return false;
        }
        if (!result.isRegistered) {
          _isNotRegistered = true;
          _errorMessage = result.message ??
              'No account found with this phone number. Please register first.';
          return false;
        }
        if (!result.hasToken && _errorMessage == null) {
          _errorMessage = result.message ?? 'Login failed. Please try again.';
        }
        return result.hasToken;
      } else {
        final result = await _repository.verifyOTP(phoneNumber, otpCode);
        return result.isVerified;
      }
    } catch (e) {
      _errorMessage ??= 'Verification failed. Please try again.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<bool> resendOTP() async {
    if (_resendCountdown > 0) return false;
    _errorMessage = null;
    _isNotRegistered = false;
    isLoading = true;
    try {
      final response = await _repository.resendOTP(
        _authRequest,
        onError: (error) {
          _errorMessage = error.message;
          _checkIfUnregistered(error);
        },
      );
      if (response.error != null && response.error!.isNotEmpty) {
        _errorMessage = response.error;
        if (!response.isRegistered ||
            response.error!.toLowerCase().contains('register')) {
          _isNotRegistered = true;
        }
        return false;
      }
      if (!response.isRegistered) {
        _isNotRegistered = true;
        _errorMessage = response.message.isNotEmpty
            ? response.message
            : 'No account found with this phone number. Please register first.';
        return false;
      }
      _sentOtp = response.otp;
      startResendTimer();
      return true;
    } catch (e) {
      _errorMessage ??= 'Failed to resend OTP. Please try again.';
      return false;
    } finally {
      isLoading = false;
    }
  }

  void _clearOtpFields() {
    for (var c in otpControllers) {
      c.clear();
    }
    notifyListeners();
  }

  void onOtpDigitChanged(int index, String value, BuildContext context) {
    if (value.isNotEmpty && index < 3) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    phoneController.dispose();
    _countdownTimer?.cancel();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
