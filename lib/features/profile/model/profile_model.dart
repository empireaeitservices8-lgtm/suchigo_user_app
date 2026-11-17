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
    final rootMap = json['data'] is Map
        ? json['data'] as Map
        : (json['profile'] is Map ? json['profile'] as Map : json);
    final userMap = rootMap['user'] is Map ? rootMap['user'] as Map : null;
    String? phone = rootMap['phone_number']?.toString() ??
        rootMap['phone']?.toString() ??
        rootMap['mobile']?.toString() ??
        rootMap['contact_number']?.toString();
    if (phone == null || phone.trim().isEmpty) {
      if (userMap != null) {
        phone = userMap['phone_number']?.toString() ??
            userMap['phone']?.toString() ??
            userMap['mobile']?.toString();
      }
    }

    final parsedUser = userMap != null
        ? UserAccountModel.fromJson(userMap)
        : (rootMap['first_name'] != null ||
                rootMap['last_name'] != null ||
                rootMap['email'] != null ||
                rootMap['username'] != null
            ? UserAccountModel.fromJson(rootMap)
            : null);

    return ProfileResponseModel(
      id: int.tryParse(rootMap['id']?.toString() ?? ''),
      phoneNumber: phone,
      address: rootMap['address']?.toString(),
      profilePicture: rootMap['profile_picture']?.toString(),
      numberOfBags:
          int.tryParse(rootMap['number_of_bags']?.toString() ?? '') ?? 0,
      walletBalance:
          double.tryParse(rootMap['wallet_balance']?.toString() ?? '') ?? 0.0,
      gender: rootMap['gender']?.toString(),
      fcmToken: rootMap['fcm_token']?.toString(),
      user: parsedUser,
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

class EditProfileRequestModel {
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? email;
  final String? address;

  const EditProfileRequestModel({
    this.firstName,
    this.lastName,
    this.gender,
    this.email,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        if (firstName != null) 'first_name': firstName!.trim(),
        if (lastName != null) 'last_name': lastName!.trim(),
        if (gender != null && gender!.trim().isNotEmpty)
          'gender': gender!.trim().toLowerCase(),
        if (email != null) 'email': email!.trim(),
        if (address != null) 'address': address!.trim(),
      };
}
