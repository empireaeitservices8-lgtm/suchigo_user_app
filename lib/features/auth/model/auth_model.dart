enum Gender {
  female,
  male,
  other,
}

enum AuthMode {
  register,
  login,
}

class AuthRequestModel {
  final String phoneNumber;
  final String countryCode;
  final AuthMode mode;

  const AuthRequestModel({
    required this.phoneNumber,
    this.countryCode = '+91',
    this.mode = AuthMode.login,
  });

  String get fullPhoneNumber {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanPhone.startsWith('+')) {
      return cleanPhone;
    }
    return '$countryCode$cleanPhone';
  }

  Map<String, dynamic> toSendOTPJson() => {
        'phone_number': fullPhoneNumber,
      };
}

/// Response of `otp/send/`
class SendOTPResponseModel {
  final String message;
  final String? otp;
  final String? error;
  final bool isRegistered;

  const SendOTPResponseModel({
    required this.message,
    this.otp,
    this.error,
    this.isRegistered = true,
  });

  factory SendOTPResponseModel.fromJson(Map<dynamic, dynamic> json) =>
      SendOTPResponseModel(
        message: json['message']?.toString() ?? json['error']?.toString() ?? '',
        otp: json['otp']?.toString(),
        error: json['error']?.toString(),
        isRegistered: json['is_registered'] == true ||
            json['is_registered']?.toString().toLowerCase() == 'true' ||
            (json['is_registered'] == null && !json.containsKey('error')),
      );
}

/// Request of `otp/verify/`
class VerifyOTPRequestModel {
  final String phoneNumber;
  final String otp;
  final String countryCode;

  const VerifyOTPRequestModel({
    required this.phoneNumber,
    required this.otp,
    this.countryCode = '+91',
  });

  String get fullPhoneNumber {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanPhone.startsWith('+')) {
      return cleanPhone;
    }
    return '$countryCode$cleanPhone';
  }

  Map<String, dynamic> toJson() => {
        'phone_number': fullPhoneNumber,
        'otp': otp,
      };
}

/// Response of `otp/verify/`
class OTPVerificationModel {
  final String message;
  final String? error;
  final bool isVerified;
  final String? token;
  final String? phoneNumber;
  final String? otp;

  const OTPVerificationModel({
    this.message = '',
    this.error,
    this.isVerified = true,
    this.token,
    this.phoneNumber,
    this.otp,
  });

  factory OTPVerificationModel.fromJson(Map<dynamic, dynamic> json) =>
      OTPVerificationModel(
        message: json['message']?.toString() ?? json['error']?.toString() ?? '',
        error: json['error']?.toString(),
        token: json['token']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        otp: json['otp']?.toString(),
        isVerified: json['error'] == null &&
            (json['message']?.toString().toLowerCase().contains('success') == true ||
                json['is_verified'] == true ||
                (json['message'] != null && json['message'].toString().isNotEmpty)),
      );
}

class LoginRequestModel {
  final String phoneNumber;
  final String otp;
  final String countryCode;

  const LoginRequestModel({
    required this.phoneNumber,
    required this.otp,
    this.countryCode = '+91',
  });

  String get fullPhoneNumber {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanPhone.startsWith('+')) {
      return cleanPhone;
    }
    return '$countryCode$cleanPhone';
  }

  Map<String, dynamic> toJson() => {
        'phone_number': fullPhoneNumber,
        'otp': otp,
      };
}

class LoginResponseModel {
  final String? token;
  final int? userId;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final bool canAccessApp;
  final String? message;
  final String? error;
  final bool isRegistered;

  const LoginResponseModel({
    this.token,
    this.userId,
    this.username,
    this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.canAccessApp = true,
    this.message,
    this.error,
    this.isRegistered = true,
  });

  bool get hasToken => token != null && token!.isNotEmpty;

  factory LoginResponseModel.fromJson(Map<dynamic, dynamic> json) =>
      LoginResponseModel(
        token: json['token']?.toString(),
        userId: int.tryParse(json['user_id']?.toString() ?? ''),
        username: json['username']?.toString(),
        email: json['email']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        firstName: json['first_name']?.toString(),
        lastName: json['last_name']?.toString(),
        canAccessApp: json['can_access_app'] == null ||
            json['can_access_app'] == true ||
            json['can_access_app']?.toString().toLowerCase() == 'true',
        message: json['message']?.toString(),
        error: json['error']?.toString(),
        isRegistered: json['is_registered'] == true ||
            json['is_registered']?.toString().toLowerCase() == 'true' ||
            (json['is_registered'] == null && !json.containsKey('error')),
      );

  String get fullName =>
      '${firstName ?? ''} ${lastName ?? ''}'.trim();
}

class CompleteProfileRequestModel {
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final Gender gender;
  final String? email;
  final String? otp;
  final String countryCode;

  const CompleteProfileRequestModel({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    this.gender = Gender.female,
    this.email,
    this.otp,
    this.countryCode = '+91',
  });

  String get fullPhoneNumber {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanPhone.startsWith('+')) {
      return cleanPhone;
    }
    if (cleanPhone.startsWith('91') && cleanPhone.length > 10) {
      return '+$cleanPhone';
    }
    return '$countryCode$cleanPhone';
  }

  Map<String, dynamic> toJson() => {
        'phone_number': fullPhoneNumber,
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender.name,
        'otp': otp ?? '',
        if (email != null && email!.isNotEmpty) 'email': email,
      };
}

/// Response of `register/`
class UserProfileModel {
  final String token;
  final int? userId;
  final String? username;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;

  const UserProfileModel({
    required this.token,
    this.userId,
    this.username,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
  });

  factory UserProfileModel.fromJson(Map<dynamic, dynamic> json) =>
      UserProfileModel(
        token: json['token']?.toString() ?? '',
        userId: int.tryParse(json['user_id']?.toString() ?? ''),
        username: json['username']?.toString(),
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phone_number']?.toString() ?? '',
        firstName: json['first_name']?.toString() ?? '',
        lastName: json['last_name']?.toString() ?? '',
      );

  String get fullName => '$firstName $lastName'.trim();
}
