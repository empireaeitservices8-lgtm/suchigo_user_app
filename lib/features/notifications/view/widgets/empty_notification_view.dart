import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyNotificationView extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmptyNotificationView({
    super.key,
    this.title = 'No notifications found',
    this.subtitle = 'No upcoming scheduled reminders.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bell Off Icon
            Icon(
              Icons.notifications_off_outlined,
              size: 72.sp,
              color: const Color(0xFFB0BEC5),
            ),
            SizedBox(height: 18.h),

            // Main Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 6.h),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
