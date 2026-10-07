import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingConfirmedDialog extends StatelessWidget {
  final String standardRate;
  final VoidCallback? onClose;

  const BookingConfirmedDialog({
    super.key,
    this.standardRate = '₹10/kg',
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    String standardRate = '₹10/kg',
    VoidCallback? onClose,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => BookingConfirmedDialog(
        standardRate: standardRate,
        onClose: onClose,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // White Dialog Box
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 36.h),
            padding: EdgeInsets.fromLTRB(20.w, 48.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Booking Confirmed!',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '🎉',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Green Highlight Message
                Text(
                  'Thank you for keeping your surroundings clean with Suchigo! Your Pickup is Scheduled. 🚚',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 14.h),

                // Descriptive Text
                Text(
                  'Please keep your waste neatly covered and secured. Our trained staff will arrive at your doorstep for a hassle-free collection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF616161),
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 16.h),

                // Standard Rate Highlight
                Text(
                  'Standard Rate: $standardRate',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: 20.h),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onClose?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7280),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top Floating Green Check Icon
          Positioned(
            top: 0,
            child: Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
