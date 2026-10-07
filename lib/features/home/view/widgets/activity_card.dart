import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActivityCard extends StatelessWidget {
  final int monthlyKg;

  const ActivityCard({
    super.key,
    this.monthlyKg = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F0),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your waste activity',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                "Great job! You've received\n${monthlyKg}kg this month!",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),

          // Right Vertical Bar Chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(height: 12.h),
              SizedBox(width: 5.w),
              _buildBar(height: 22.h),
              SizedBox(width: 5.w),
              _buildBar(height: 34.h),
              SizedBox(width: 5.w),
              _buildBar(height: 48.h),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar({required double height}) {
    return Container(
      width: 7.w,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF00C853),
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
