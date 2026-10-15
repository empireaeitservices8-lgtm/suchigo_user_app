class ProfileResponseModel {
  final int? id;
  final String? phoneNumber;
  final String? address;
  final String? profilePicture;
  final UserAccountModel? user;
  final int numberOfBags;
  final double walletBalance;
  final String? gender;
  final String? fcmToken;

  const ProfileResponseModel({
    this.id,
    this.phoneNumber,
    this.address,
    this.profilePicture,
    this.user,
    this.numberOfBags = 0,
    this.walletBalance = 0.0,
    this.gender,
    this.fcmToken,
  });

  factory ProfileResponseModel.fromJson(Map<dynamic, dynamic> json) {
    final userMap = json['user'] is Map ? json['user'] as Map : null;
    String? phone = json['phone_number']?.toString() ??
        json['phone']?.toString() ??
        json['mobile']?.toString() ??
        json['contact_number']?.toString();
    if (phone == null || phone.trim().isEmpty) {
      if (userMap != null) {
        phone = userMap['phone_number']?.toString() ??
            userMap['phone']?.toString() ??
            userMap['mobile']?.toString();
      }
    }

    return ProfileResponseModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      phoneNumber: phone,
      address: json['address']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
      numberOfBags:
          int.tryParse(json['number_of_bags']?.toString() ?? '') ?? 0,
      walletBalance:
          double.tryParse(json['wallet_balance']?.toString() ?? '') ?? 0.0,
      gender: json['gender']?.toString(),
      fcmToken: json['fcm_token']?.toString(),
      user: userMap != null ? UserAccountModel.fromJson(userMap) : null,
    );
  }

  String get fullName {
    final name = user?.fullName;
    return (name != null && name.isNotEmpty) ? name : 'User';
  }

  String get displayPhone {
    if (phoneNumber != null && phoneNumber!.trim().isNotEmpty) {
      final digits = phoneNumber!.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= 10 && !digits.contains('7592964952')) {
        return phoneNumber!.trim();
      }
    }
    if (user?.username != null && user!.username!.trim().isNotEmpty) {
      final digits = user!.username!.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length >= 10 && !digits.contains('7592964952')) {
        return user!.username!.trim();
      }
    }
    return '';
  }
  String get email => user?.email ?? '';
  String get username => user?.username ?? '';
}

class UserAccountModel {
  final int? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;

  const UserAccountModel({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
  });

  factory UserAccountModel.fromJson(Map<dynamic, dynamic> json) =>
      UserAccountModel(
        id: int.tryParse(json['id']?.toString() ?? ''),
        username: json['username']?.toString(),
        email: json['email']?.toString(),
        firstName: json['first_name']?.toString(),
        lastName: json['last_name']?.toString(),
      );

  String get fullName =>
      '${firstName ?? ''} ${lastName ?? ''}'.trim();
}
