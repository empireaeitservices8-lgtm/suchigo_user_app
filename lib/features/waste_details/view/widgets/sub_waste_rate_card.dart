import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/waste_details_model.dart';

class SubWasteRateCard extends StatelessWidget {
  final SubWasteRateModel model;

  const SubWasteRateCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
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
      child: Row(
        children: [
          // Recycle Icon Badge
          Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F6EF),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.autorenew_rounded,
                color: Color(0xFF166534),
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 14.w),

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  model.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  model.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Price Tag
          Text(
            model.ratePerKg,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF166534),
            ),
          ),
        ],
      ),
    );
  }
}
