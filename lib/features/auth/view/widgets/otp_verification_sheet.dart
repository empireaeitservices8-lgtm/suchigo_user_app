import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../model/auth_model.dart';
import '../../view_model/auth_view_model.dart';
import 'package:suchigo_user_app/widgets/app_button_widget.dart';
import '../complete_profile_screen.dart';

class OTPVerificationSheet extends StatelessWidget {
  final VoidCallback onVerificationSuccess;

  const OTPVerificationSheet({
    super.key,
    required this.onVerificationSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 12.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 42.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),

          // Green Padlock with User Badge Icon
          _buildSecurityIcon(),
          SizedBox(height: 18.h),

          // Title
          Text(
            'Security Verification',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F4A26),
            ),
          ),
          SizedBox(height: 8.h),

          // Subtitle
          Text(
            'We sent a 4-digit verification code to:\n${vm.fullPhoneNumber}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),
          SizedBox(height: 28.h),

          // 4 OTP Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final isFocused = vm.otpFocusNodes[index].hasFocus;
              final hasValue = vm.otpControllers[index].text.isNotEmpty;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                width: 58.w,
                height: 58.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isFocused || hasValue
                        ? const Color(0xFF166534)
                        : const Color(0xFFE2E8F0),
                    width: isFocused ? 2.0 : 1.2,
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: vm.otpControllers[index],
                    focusNode: vm.otpFocusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F4A26),
                    ),
                    decoration: const InputDecoration(
                      filled: false,
                      fillColor: Colors.transparent,
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      vm.onOtpDigitChanged(index, val, context);
                    },
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 22.h),

          // Resend Timer / Action
          if (vm.resendCountdown > 0)
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Resend code in ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: '${vm.resendCountdown}s',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            )
          else
            InkWell(
              onTap: vm.isLoading ? null : () => vm.resendOTP(),
              child: Text(
                'Resend Code',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF166534),
                ),
              ),
            ),
          SizedBox(height: 28.h),

          // Verify & Continue Button
          AppButton(
            text: 'Verify & Continue',
            isEnabled: vm.isOtpComplete,
            isLoading: vm.isLoading,
            onTap: () async {
              final success = await vm.verifyOTP();
              if (!context.mounted) return;
              if (success) {
                Navigator.pop(context);
                if (vm.mode == AuthMode.register) {
                  Navigator.pushNamed(
                    context,
                    CompleteProfileScreen.routeName,
                    arguments: CompleteProfileScreenArgs(
                      phoneNumber: vm.fullPhoneNumber,
                      otp: vm.otpCode,
                    ),
                  );
                } else {
                  onVerificationSuccess();
                }
              } else if (vm.isNotRegistered) {
                vm.setMode(AuthMode.register);
                final verifySuccess = await vm.verifyOTP();
                if (!context.mounted) return;
                if (verifySuccess) {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    CompleteProfileScreen.routeName,
                    arguments: CompleteProfileScreenArgs(
                      phoneNumber: vm.fullPhoneNumber,
                      otp: vm.otpCode,
                    ),
                  );
                } else if (vm.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(vm.errorMessage!),
                    ),
                  );
                }
              } else if (vm.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(vm.errorMessage!),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityIcon() {
    return SizedBox(
      width: 48.w,
      height: 48.w,
      child: CustomPaint(
        painter: _PadlockPainter(),
      ),
    );
  }
}

class _PadlockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final greenStroke = Paint()
      ..color = const Color(0xFF166534)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final greenFill = Paint()
      ..color = const Color(0xFF166534)
      ..style = PaintingStyle.fill;

    // Shackle (Arch on top)
    final shacklePath = Path();
    shacklePath.moveTo(w * 0.32, h * 0.42);
    shacklePath.lineTo(w * 0.32, h * 0.28);
    shacklePath.arcTo(
      Rect.fromLTWH(w * 0.32, h * 0.12, w * 0.36, h * 0.32),
      3.14159,
      3.14159,
      false,
    );
    shacklePath.lineTo(w * 0.68, h * 0.42);
    canvas.drawPath(shacklePath, greenStroke);

    // Lock Body
    final lockBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.42, w * 0.52, h * 0.48),
      const Radius.circular(8),
    );
    canvas.drawRRect(lockBody, greenStroke);

    // User Silhouette inside lock badge (bottom right)
    final userBadgeCenter = Offset(w * 0.58, h * 0.68);
    canvas.drawCircle(userBadgeCenter, 7, greenFill);

    // User Head inside badge (white)
    canvas.drawCircle(
      Offset(userBadgeCenter.dx, userBadgeCenter.dy - 2),
      2,
      Paint()..color = Colors.white,
    );
    // User Shoulders (white)
    final shoulders = Path();
    shoulders.arcTo(
      Rect.fromCircle(
        center: Offset(userBadgeCenter.dx, userBadgeCenter.dy + 4),
        radius: 3.5,
      ),
      3.14159,
      3.14159,
      false,
    );
    canvas.drawPath(
      shoulders,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
