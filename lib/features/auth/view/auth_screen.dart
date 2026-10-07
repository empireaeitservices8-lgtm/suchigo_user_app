import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_user_app/features/home/view/home_screen.dart';
import 'package:suchigo_user_app/features/onboarding/view/widgets/suchigo_logo_widget.dart';
import '../model/auth_model.dart';
import '../view_model/auth_view_model.dart';
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

  void _showOTPBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: OTPVerificationSheet(
          onVerificationSuccess: () {
            if (_viewModel.mode == AuthMode.register) {
              Navigator.pushNamed(
                context,
                CompleteProfileScreen.routeName,
                arguments: CompleteProfileScreenArgs(
                  phoneNumber: _viewModel.phoneNumber,
                  otp: _viewModel.otpCode,
                ),
              );
            } else {
              Navigator.pushReplacementNamed(context, HomeScreen.routeName);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F8F4),
        body: Consumer<AuthViewModel>(
          builder: (context, vm, child) {
            final isRegister = vm.mode == AuthMode.register;

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
                            color: const Color(0xFF166534).withValues(alpha: 0.08),
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
                            isRegister ? 'Get Started' : 'Welcome Back',
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F4A26),
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Subtitle
                          Text(
                            isRegister
                                ? 'Create an account to begin your journey'
                                : 'Sign in to access your account',
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
                              color: const Color(0xFFFAFCFA),
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
                                      counterText: '',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Send OTP Button
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: vm.isPhoneValid && !vm.isLoading
                                  ? () async {
                                      final sent = await vm.sendOTP();
                                      if (!context.mounted) return;
                                      if (sent) {
                                        _showOTPBottomSheet();
                                      } else if (vm.isNotRegistered) {
                                        vm.setMode(AuthMode.register);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            vm.errorMessage ??
                                                'No account found. Switched to Register mode.',
                                          ),
                                          backgroundColor:
                                              const Color(0xFF166534),
                                        ));
                                      } else if (vm.errorMessage != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(vm.errorMessage!),
                                        ));
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: vm.isPhoneValid
                                    ? const Color(0xFF166534)
                                    : const Color(0xFFE2E8F0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: vm.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Send OTP',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: vm.isPhoneValid
                                                ? Colors.white
                                                : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Icon(
                                          Icons.east_rounded,
                                          color: vm.isPhoneValid
                                              ? Colors.white
                                              : const Color(0xFF94A3B8),
                                          size: 18,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Footer Mode Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isRegister
                                    ? 'Existing user? '
                                    : 'New user? ',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  vm.toggleMode();
                                },
                                child: Text(
                                  isRegister ? 'Login' : 'Get Started',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF166534),
                                  ),
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
