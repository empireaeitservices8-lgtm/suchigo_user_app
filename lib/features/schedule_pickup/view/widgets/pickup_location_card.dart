import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PickupLocationCard extends StatelessWidget {
  final TextEditingController addressController;
  final TextEditingController zipCodeController;
  final VoidCallback onSelectOnMap;

  const PickupLocationCard({
    super.key,
    required this.addressController,
    required this.zipCodeController,
    required this.onSelectOnMap,
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
                Icons.location_on_rounded,
                color: Color(0xFF166534),
                size: 20,
              ),
              SizedBox(width: 8.w),
              Text(
                'Pickup Location',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // "Select Address on Map" Button
          InkWell(
            onTap: onSelectOnMap,
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              width: double.infinity,
              height: 48.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: const Color(0xFF166534),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    color: Color(0xFF166534),
                    size: 20,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Select Address on Map',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 18.h),

          // Pickup Address Field
          _buildFieldLabel('Pickup Address', isRequired: true),
          SizedBox(height: 6.h),
          Container(
            height: 90.h,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCFA),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: addressController,
              maxLines: null,
              expands: true,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: 'Enter your complete address',
                hintStyle: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFB0BEC5),
                ),
                contentPadding: EdgeInsets.all(14.w),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Zip / Postal Code Field
          _buildFieldLabel('Zip / Postal Code', isRequired: true),
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
              controller: zipCodeController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: 'Enter zip code',
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
