import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:suchigo_user_app/config/app_config.dart';

class CustomToast {
  static FToast? _fToast;

  /// Global toast matching the app's dark floating banner style.
  static void show(
    BuildContext? context, {
    required String message,
    IconData icon = Icons.warning_amber_rounded,
    Color iconColor = const Color(0xFFDE9F32),
    Color iconBgColor = const Color(0xFF453E32),
    Color backgroundColor = const Color(0xFF1E2A3A),
    double? bottomOffset,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    final ctx = context ?? AppConfig.navKey.currentContext;
    if (ctx == null) {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: backgroundColor,
        textColor: Colors.white,
      );
      return;
    }

    _fToast ??= FToast();
    _fToast!.init(ctx);
    _fToast!.removeCustomToast();

    final safeBottom = MediaQuery.of(ctx).padding.bottom;
    final effectiveBottom = bottomOffset ?? (84.h + safeBottom);

    _fToast!.showToast(
      toastDuration: duration,
      fadeDuration: const Duration(milliseconds: 250),
      gravity: ToastGravity.BOTTOM,
      positionedToastBuilder: (context, child, gravity) {
        return Positioned(
          bottom: effectiveBottom,
          left: 18.w,
          right: 18.w,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circle badge with icon
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Alert message text
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays a custom warning banner toast matching the app's disabled item style.
  static void showDisabledAlert(
    BuildContext? context, {
    String message = 'E-Waste collection is currently disabled.',
    double? bottomOffset,
  }) {
    show(
      context,
      message: message,
      bottomOffset: bottomOffset,
    );
  }
}
