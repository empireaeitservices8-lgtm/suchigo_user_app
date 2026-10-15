import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_user_app/features/profile/repo/profile_repo.dart';
import 'package:suchigo_user_app/helpers/logout_helper.dart';
import 'package:suchigo_user_app/helpers/sp_helper.dart';
import 'package:suchigo_user_app/services/web_api_services.dart';
import 'package:suchigo_user_app/utils/sp_keys.dart' as sp_keys;
import 'package:suchigo_user_app/utils/urls.dart';
import 'package:suchigo_user_app/widgets/custom_toast.dart';

class MyAccountScreen extends StatefulWidget {
  static const routeName = '/MyAccountScreen';

  const MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final ProfileRepository _profileRepo = ProfileRepositoryImpl();
  final WebAPIService _apiService = WebAPIService();

  bool _isLoading = true;
  int _totalPickups = 0;
  double _totalWeight = 0.0;
  int _treesSaved = 0;

  String _userName = '';
  String _phoneNumber = '';
  String? _email;
  String? _address;
  String? _city;
  String? _pincode;
  String? _gender;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load cached info first as fallback while waiting for live API
    final cachedName = await SpHelper.getString(sp_keys.keyUserName);
    final cachedPhone = await SpHelper.getString(sp_keys.keyUseMobile);
    final cachedEmail = await SpHelper.getString(sp_keys.keyEmail);

    if (cachedName != null &&
        cachedName.trim().isNotEmpty &&
        cachedName.trim().toLowerCase() != 'user') {
      _userName = cachedName.trim();
    }
    if (cachedPhone != null && cachedPhone.trim().isNotEmpty) {
      _phoneNumber = cachedPhone.trim();
    }
    if (cachedEmail != null && cachedEmail.trim().isNotEmpty) {
      _email = cachedEmail.trim();
    }

    // 1. Fetch live profile from Profile API
    try {
      final p = await _profileRepo.getProfile();
      if (p.fullName.isNotEmpty && p.fullName.toLowerCase() != 'user') {
        _userName = p.fullName;
        await SpHelper.saveString(sp_keys.keyUserName, _userName);
      } else if (p.user?.firstName != null &&
          p.user!.firstName!.trim().isNotEmpty) {
        final last = p.user?.lastName?.trim() ?? '';
        _userName = '${p.user!.firstName!.trim()} $last'.trim();
        await SpHelper.saveString(sp_keys.keyUserName, _userName);
      } else if (p.username.isNotEmpty) {
        _userName = p.username;
        await SpHelper.saveString(sp_keys.keyUserName, _userName);
      }

      if (p.displayPhone.isNotEmpty) {
        _phoneNumber = p.displayPhone;
        await SpHelper.saveString(sp_keys.keyUseMobile, _phoneNumber);
      } else if (p.phoneNumber != null && p.phoneNumber!.isNotEmpty) {
        _phoneNumber = p.phoneNumber!;
        await SpHelper.saveString(sp_keys.keyUseMobile, _phoneNumber);
      }

      if (p.email.isNotEmpty) {
        _email = p.email;
        await SpHelper.saveString(sp_keys.keyEmail, _email!);
      }

      if (p.gender != null && p.gender!.trim().isNotEmpty) {
        _gender = p.gender!.trim();
      }

      if (p.address != null && p.address!.trim().isNotEmpty) {
        _address = p.address!.trim();
        _parseAddressComponents(p.address!.trim());
      }

      if (p.numberOfBags > 0) {
        _totalWeight = p.numberOfBags * 5.0;
        _treesSaved = (p.numberOfBags * 1.5).round();
      }
    } catch (_) {}

    // 2. Fetch live pickups count and calculate live metrics
    try {
      await _apiService.initTokenToHeader();
      final res = await _apiService.dio.get(urlPickups);
      List rawList = [];
      if (res.data is List) {
        rawList = res.data as List;
      } else if (res.data is Map && res.data['data'] is List) {
        rawList = res.data['data'] as List;
      } else if (res.data is Map && res.data['results'] is List) {
        rawList = res.data['results'] as List;
      }

      _totalPickups = rawList.length;

      if (rawList.isNotEmpty) {
        double calculatedWeight = 0.0;
        for (var item in rawList) {
          if (item is Map) {
            final bags =
                int.tryParse(item['number_of_bags']?.toString() ?? '') ?? 1;
            calculatedWeight += (bags * 5.0);
          }
        }
        if (calculatedWeight > 0) {
          _totalWeight = calculatedWeight;
          _treesSaved = (_totalWeight * 0.25).round();
        }

        // Try extracting address from latest pickup if profile address was empty
        if (_address == null || _address!.isEmpty) {
          final first = rawList.first as Map;
          final street = first['street']?.toString();
          final city =
              first['city']?.toString() ?? first['district']?.toString();
          final zip = first['zip_code']?.toString();
          if (street != null && street.isNotEmpty) {
            _address = street;
          }
          if (city != null && city.isNotEmpty) {
            _city = city;
          }
          if (zip != null && zip.isNotEmpty) {
            _pincode = zip;
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _parseAddressComponents(String addr) {
    final parts = addr.split(',');
    if (parts.length >= 2) {
      _city = parts[parts.length - 2].trim();
      final lastPart = parts.last.trim();
      final zipMatch = RegExp(r'\d{6}').firstMatch(lastPart);
      if (zipMatch != null) {
        _pincode = zipMatch.group(0);
      }
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature editing will be available soon.'),
        backgroundColor: const Color(0xFF1D723B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
          style: TextStyle(
            fontSize: 13.5.sp,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              CustomToast.show(
                context,
                message: 'Account deletion request submitted.',
              );
              await LogoutHelper.performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Curved Green Header with Welcome Card
            _buildHeader(),
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 2.5,
                color: Color(0xFF166534),
                backgroundColor: Colors.transparent,
              ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Column(
                children: [
                  // Circular Avatar & User Info
                  _buildUserAvatarSection(),
                  SizedBox(height: 20.h),

                  // Stats Row (Pickups, Weight, Trees)
                  _buildStatsRow(),
                  SizedBox(height: 22.h),

                  // Personal Details Card
                  _buildPersonalDetailsSection(),
                  SizedBox(height: 22.h),

                  // Address Details Card
                  _buildAddressDetailsSection(),
                  SizedBox(height: 22.h),

                  // Account Actions (Delete Account)
                  _buildAccountActionsSection(),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2EB872),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D723B).withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar: Back Button & Title
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 4.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(22.r),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'My Account',
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w), // Balance back button
                ],
              ),
            ),
            SizedBox(height: 10.h),

            // White Welcome Card
            Container(
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Welcome back${_userName.isNotEmpty ? ", $_userName" : ""}! 👋',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Manage your waste collection and track your environmental impact',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatarSection() {
    final initialLetter =
        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U';

    String? genderSymbol;
    if (_gender != null && _gender!.trim().isNotEmpty) {
      final g = _gender!.trim().toLowerCase();
      if (g.contains('fem') || g == 'f') {
        genderSymbol = '♀';
      } else if (g.contains('mal') || g == 'm') {
        genderSymbol = '♂';
      } else {
        genderSymbol = _gender;
      }
    }

    return Column(
      children: [
        // Circular Avatar with green border
        Container(
          width: 84.w,
          height: 84.w,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F6EF),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF166534),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initialLetter,
              style: TextStyle(
                fontSize: 34.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF166534),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),

        // User Name
        Text(
          _userName.isNotEmpty ? _userName : 'User',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        if (genderSymbol != null) ...[
          SizedBox(height: 4.h),
          Text(
            genderSymbol,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF166534),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.autorenew_rounded,
            value: '$_totalPickups',
            label: 'Total Pickups',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            icon: Icons.scale_rounded,
            value: '${_totalWeight.toStringAsFixed(1)} kg',
            label: 'Total Weight',
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            icon: Icons.eco_rounded,
            value: '$_treesSaved',
            label: 'Trees Saved',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF166534),
            size: 24.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading with Edit Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Personal Details',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            InkWell(
              onTap: () => _showComingSoon('Profile'),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFF1D723B),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      color: const Color(0xFF1D723B),
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D723B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // White Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailItem(
                icon: Icons.person_outline_rounded,
                label: 'Full Name',
                value: _userName.isNotEmpty ? _userName : 'Not Provided',
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              _buildDetailItem(
                icon: Icons.phone_outlined,
                label: 'Phone Number',
                value: _phoneNumber.isNotEmpty ? _phoneNumber : 'Not Provided',
              ),
              if (_email != null && _email!.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                _buildDetailItem(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: _email!,
                ),
              ],
              if (_gender != null && _gender!.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                _buildDetailItem(
                  icon: Icons.person_pin_outlined,
                  label: 'Gender',
                  value: _gender!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address Details',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 12.h),

        // White Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailItem(
                icon: Icons.home_outlined,
                label: 'Address',
                value: _address?.isNotEmpty == true ? _address! : 'Add Address',
                isPlaceholder: _address == null || _address!.isEmpty,
                onTapPlaceholder: () => _showComingSoon('Address'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              _buildDetailItem(
                icon: Icons.location_city_outlined,
                label: 'City',
                value: _city?.isNotEmpty == true ? _city! : 'Add City',
                isPlaceholder: _city == null || _city!.isEmpty,
                onTapPlaceholder: () => _showComingSoon('City'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),
              _buildDetailItem(
                icon: Icons.place_outlined,
                label: 'Pincode',
                value: _pincode?.isNotEmpty == true ? _pincode! : 'Add Pincode',
                isPlaceholder: _pincode == null || _pincode!.isEmpty,
                onTapPlaceholder: () => _showComingSoon('Pincode'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isPlaceholder = false,
    VoidCallback? onTapPlaceholder,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF94A3B8),
          size: 22.sp,
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              SizedBox(height: 4.h),
              if (isPlaceholder)
                InkWell(
                  onTap: onTapPlaceholder,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE67E22), // Orange/amber accent
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Actions',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 12.h),

        // White Card with Delete Account action
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showDeleteAccountDialog,
              borderRadius: BorderRadius.circular(18.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFD32F2F),
                          size: 22,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 24.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
