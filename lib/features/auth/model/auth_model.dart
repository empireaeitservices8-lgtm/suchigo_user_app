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
    this.mode = AuthMode.register,
  });

  String get fullPhoneNumber => '$countryCode$phoneNumber';

  Map<String, dynamic> toSendOTPJson() => {
        'phone_number': phoneNumber,
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

class OTPVerificationModel {
  final String phoneNumber;
  final String otp;
  final bool isVerified;
  final String? token;

  const OTPVerificationModel({
    required this.phoneNumber,
    required this.otp,
    this.isVerified = false,
    this.token,
  });
}

class LoginRequestModel {
  final String phoneNumber;
  final String otp;

  const LoginRequestModel({
    required this.phoneNumber,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'phone_number': phoneNumber,
        'otp': otp,
      };
}

class LoginResponseModel {
  final String? token;
  final int? userId;
  final String? email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? message;
  final String? error;
  final bool isRegistered;

  const LoginResponseModel({
    this.token,
    this.userId,
    this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.message,
    this.error,
    this.isRegistered = true,
  });

  bool get hasToken => token != null && token!.isNotEmpty;

  factory LoginResponseModel.fromJson(Map<dynamic, dynamic> json) =>
      LoginResponseModel(
        token: json['token']?.toString(),
        userId: int.tryParse(json['user_id']?.toString() ?? ''),
        email: json['email']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        firstName: json['first_name']?.toString(),
        lastName: json['last_name']?.toString(),
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
  final String otp;
  final Gender? gender;

  const CompleteProfileRequestModel({
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.otp,
    this.gender,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phoneNumber,
        'otp': otp,
        if (gender != null) 'gender': gender!.name,
      };
}

/// Response of `register/`
class UserProfileModel {
  final String token;
  final int? userId;
  final String email;
  final String phoneNumber;
  final String firstName;
  final String lastName;

  const UserProfileModel({
    required this.token,
    this.userId,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
  });

  factory UserProfileModel.fromJson(Map<dynamic, dynamic> json) =>
      UserProfileModel(
        token: json['token']?.toString() ?? '',
        userId: int.tryParse(json['user_id']?.toString() ?? ''),
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phone_number']?.toString() ?? '',
        firstName: json['first_name']?.toString() ?? '',
        lastName: json['last_name']?.toString() ?? '',
      );

  String get fullName => '$firstName $lastName'.trim();
}
