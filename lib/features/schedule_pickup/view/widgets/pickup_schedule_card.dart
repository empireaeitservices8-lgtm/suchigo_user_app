import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class PickupScheduleCard extends StatelessWidget {
  final DateTime? pickupDate;
  final TextEditingController bagsCountController;
  final VoidCallback onSelectDate;

  const PickupScheduleCard({
    super.key,
    required this.pickupDate,
    required this.bagsCountController,
    required this.onSelectDate,
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
                Icons.calendar_today_rounded,
                color: Color(0xFF166534),
                size: 20,
              ),
              SizedBox(width: 8.w),
              Text(
                'Pickup Schedule',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Pickup Date Field
          _buildFieldLabel('Pickup Date', isRequired: true),
          SizedBox(height: 6.h),
          InkWell(
            onTap: onSelectDate,
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              height: 52.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    pickupDate != null
                        ? DateFormat('EEE, MMM dd, yyyy').format(pickupDate!)
                        : 'Tap to select pickup date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: pickupDate != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: pickupDate != null
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFB0BEC5),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF166534),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 6.h),

          SizedBox(height: 16.h),

          // Number of Bags Field
          _buildFieldLabel('Number of Bags', isRequired: true),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: bagsCountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
        ],
      ),
    );
  }
}
