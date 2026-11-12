import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_user_app/features/home/view/home_screen.dart';
import 'package:suchigo_user_app/features/onboarding/view/widgets/suchigo_logo_widget.dart';
import '../view_model/auth_view_model.dart';
import 'package:suchigo_user_app/widgets/app_button_widget.dart';
import 'package:suchigo_user_app/widgets/custom_toast.dart';
import 'complete_profile_screen.dart';
import 'widgets/otp_verification_sheet.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/AuthScreen';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AuthViewModel();
  }

  void _showOTPBottomSheet() async {
    final verified = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: OTPVerificationSheet(
          onVerificationSuccess: () {
            Navigator.pop(sheetContext, true);
          },
        ),
      ),
    );

    if (!mounted || verified != true) return;

    if (!_viewModel.isRegistered) {
      CustomToast.show(
        context,
        message: 'Please complete your profile to register.',
      );
      Navigator.pushNamed(
        context,
        CompleteProfileScreen.routeName,
        arguments: CompleteProfileScreenArgs(
          phoneNumber: _viewModel.fullPhoneNumber,
          otp: _viewModel.otpCode,
        ),
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        HomeScreen.routeName,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F8F4),
        body: Consumer<AuthViewModel>(
          builder: (context, vm, child) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 36.h),

                    // Top Circular Logo Badge
                    Container(
                      width: 140.w,
                      height: 140.w,
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
                        child: SuchiGoLogoWidget(
                          size: 100,
                          showTagline: true,
                          showText: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Main Auth Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 32.h,
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
                          // Heading
                          Text(
                            'Enter Mobile Number',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F4A26),
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Subtitle
                          Text(
                            'Enter your phone number to get started. We will send an OTP to verify.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          SizedBox(height: 28.h),

                          // Phone Number Input Box
                          Container(
                            height: 56.h,
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
                                // Green Phone Icon
                                const Icon(
                                  Icons.phone_android_rounded,
                                  color: Color(0xFF166534),
                                  size: 22,
                                ),
                                SizedBox(width: 8.w),

                                // Country Code
                                Text(
                                  '+91',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(width: 12.w),

                                // Vertical Divider
                                Container(
                                  width: 1.2,
                                  height: 24.h,
                                  color: const Color(0xFFE2E8F0),
                                ),
                                SizedBox(width: 12.w),

                                // Number TextField
                                Expanded(
                                  child: TextField(
                                    controller: vm.phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter Phone Number',
                                      hintStyle: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      filled: false,
                                      fillColor: Colors.transparent,
                                      counterText: '',
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Send OTP Button
                          AppButton(
                            text: 'Send OTP',
                            isEnabled: vm.isPhoneValid,
                            isLoading: vm.isLoading,
                            suffixIcon: Icon(
                              Icons.east_rounded,
                              color: vm.isPhoneValid
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                              size: 18.sp,
                            ),
                            onTap: () async {
                              final sent = await vm.sendOTP();
                              if (!context.mounted) return;
                              if (sent) {
                                _showOTPBottomSheet();
                              } else if (vm.errorMessage != null) {
                                CustomToast.show(
                                  context,
                                  message: vm.errorMessage!,
                                );
                              }
                            },
                          ),
                          SizedBox(height: 24.h),

                          // Security and Terms Footer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                size: 16,
                                color: Color(0xFF166534),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Fast & secure verification via OTP',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
