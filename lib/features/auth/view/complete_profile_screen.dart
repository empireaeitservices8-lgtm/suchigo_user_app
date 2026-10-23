import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_user_app/features/home/view/home_screen.dart';
import '../model/auth_model.dart';
import '../view_model/complete_profile_view_model.dart';
import 'package:suchigo_user_app/widgets/app_button_widget.dart';
import 'package:suchigo_user_app/widgets/custom_toast.dart';

class CompleteProfileScreenArgs {
  final String phoneNumber;
  final String otp;

  const CompleteProfileScreenArgs({
    required this.phoneNumber,
    required this.otp,
  });
}

class CompleteProfileScreen extends StatefulWidget {
  static const routeName = '/CompleteProfileScreen';

  final String phoneNumber;
  final String otp;

  const CompleteProfileScreen({
    super.key,
    required this.phoneNumber,
    required this.otp,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late CompleteProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CompleteProfileViewModel(
      phoneNumber: widget.phoneNumber,
      otp: widget.otp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F8F4),
        body: Consumer<CompleteProfileViewModel>(
          builder: (context, vm, child) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),

                    // Top Left Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(24.r),
                        child: Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: Color(0xFF166534),
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Center Circular Logo Badge
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF166534).withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/splash_logo.png',
                          width: 95.w,
                          height: 95.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Main Complete Profile Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 28.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            'Complete Profile',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F4A26),
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Subtitle
                          Text(
                            'Just a few more details to set up your account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Phone Number Pill Container
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9)
                                  .withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: const Color(0xFFD1E7DD),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.phone_android_rounded,
                                  color: Color(0xFF166534),
                                  size: 18,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  vm.formattedPhoneNumber,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Change',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF166534),
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      const Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF166534),
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // First Name Input Field
                          _buildInputField(
                            controller: vm.firstNameController,
                            hintText: 'First Name',
                            icon: Icons.person_outline_rounded,
                          ),

                          SizedBox(height: 16.h),

                          // Last Name Input Field
                          _buildInputField(
                            controller: vm.lastNameController,
                            hintText: 'Last Name',
                            icon: Icons.person_outline_rounded,
                          ),

                          SizedBox(height: 20.h),

                          // Gender Section Label
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Gender',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),

                          // Gender Toggle Row (Female / Male)
                          Row(
                            children: [
                              // Female Option
                              Expanded(
                                child: _buildGenderOption(
                                  gender: Gender.female,
                                  label: 'Female',
                                  icon: Icons.female_rounded,
                                  isSelected:
                                      vm.selectedGender == Gender.female,
                                  onTap: () => vm.setGender(Gender.female),
                                ),
                              ),
                              SizedBox(width: 14.w),

                              // Male Option
                              Expanded(
                                child: _buildGenderOption(
                                  gender: Gender.male,
                                  label: 'Male',
                                  icon: Icons.male_rounded,
                                  isSelected:
                                      vm.selectedGender == Gender.male,
                                  onTap: () => vm.setGender(Gender.male),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 28.h),

                          // Create Account Button
                          AppButton(
                            text: 'Create Account',
                            isEnabled: vm.isFormValid,
                            isLoading: vm.isLoading,
                            suffixIcon: Icon(
                              Icons.check_circle_outline_rounded,
                              color: vm.isFormValid
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                              size: 20.sp,
                            ),
                            onTap: () async {
                              final success = await vm.createAccount();
                              if (!context.mounted) return;
                              if (success) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  HomeScreen.routeName,
                                  (route) => false,
                                );
                              } else if (vm.errorMessage != null) {
                                CustomToast.show(
                                  context,
                                  message: vm.errorMessage!,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Container(
      height: 54.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF166534),
            size: 22,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                ),
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffix != null) ...[
            SizedBox(width: 8.w),
            suffix,
          ],
        ],
      ),
    );
  }

  Widget _buildGenderOption({
    required Gender gender,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50.h,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFFAFCFA),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF166534)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF166534)
                  : const Color(0xFF64748B),
              size: 22,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF166534)
                    : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
