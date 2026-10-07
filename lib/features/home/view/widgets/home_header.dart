import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_user_app/features/onboarding/view/widgets/suchigo_logo_widget.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final double progress;

  const HomeHeader({
    super.key,
    this.userName = 'USER',
    this.progress = 0.65,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 18.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF00BFA5),
            Color(0xFF00C853),
            Color(0xFF26A69A),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // User Avatar Circle
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00C853),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // User Name & Progress Indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 5.h),
                // Progress Bar
                Container(
                  width: 90.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Notification Bell with Badge
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/NotificationScreen');
              },
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),

            // SuchiGo Pill Badge on Top Right
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SuchiGoLogoWidget(
                    size: 28,
                    showTagline: false,
                    showText: false,
                  ),
                  SizedBox(width: 6.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SuchiGo',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF138848),
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Schedule. Collect. Sustain',
                        style: TextStyle(
                          fontSize: 6.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF78909C),
                          height: 1.1,
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
  }
}
