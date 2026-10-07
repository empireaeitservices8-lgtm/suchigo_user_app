import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsCards extends StatelessWidget {
  final int treesSaved;
  final int rewardPoints;
  final int kgGives;

  const StatsCards({
    super.key,
    this.treesSaved = 11235,
    this.rewardPoints = 300,
    this.kgGives = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Card: Trees Saved
        Expanded(
          child: Container(
            height: 96.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F0),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Row(
              children: [
                // Black Circle with Pine Tree
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.park_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // Trees Count & Label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Trees',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _formatNumber(treesSaved),
                      style: TextStyle(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 14.w),

        // Right Card: Reward Points
        Expanded(
          child: Container(
            height: 96.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$rewardPoints ',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      TextSpan(
                        text: 'Pks',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${kgGives}KG GIVES',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int num) {
    return num.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
