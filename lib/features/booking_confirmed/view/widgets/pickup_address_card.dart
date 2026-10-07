import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingPickupAddressCard extends StatelessWidget {
  final String contactName;
  final String phone;
  final String address;

  const BookingPickupAddressCard({
    super.key,
    required this.contactName,
    required this.phone,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Pickup Address',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          SizedBox(height: 14.h),

          // Contact Row
          _buildRow(
            icon: Icons.person_outline_rounded,
            label: 'Contact',
            value: contactName,
          ),
          SizedBox(height: 12.h),

          // Phone Row
          _buildRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: phone,
          ),
          SizedBox(height: 12.h),

          // Address Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.home_outlined,
                color: Color(0xFF9E9E9E),
                size: 18,
              ),
              SizedBox(width: 10.w),
              Text(
                'Address',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757575),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  address,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF9E9E9E),
          size: 18,
        ),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF757575),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
