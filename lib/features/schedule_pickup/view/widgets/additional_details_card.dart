import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdditionalDetailsCard extends StatelessWidget {
  final TextEditingController secondaryNumberController;
  final TextEditingController landmarkController;

  const AdditionalDetailsCard({
    super.key,
    required this.secondaryNumberController,
    required this.landmarkController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.info_rounded,
                color: Color(0xFF166534),
                size: 20,
              ),
              SizedBox(width: 8.w),
              Text(
                'Additional Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Secondary Number Field
          Text(
            'Secondary Number',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCFA),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: secondaryNumberController,
              keyboardType: TextInputType.phone,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: 'Enter alternative contact number',
                hintStyle: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFB0BEC5),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Location / Landmark Field
          Text(
            'Location / Landmark',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCFA),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: landmarkController,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: 'Enter nearby landmark',
                hintStyle: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFB0BEC5),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
