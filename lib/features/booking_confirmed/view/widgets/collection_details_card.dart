import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CollectionDetailsCard extends StatelessWidget {
  final String wasteType;
  final String collectionDate;
  final String estWeight;

  const CollectionDetailsCard({
    super.key,
    required this.wasteType,
    required this.collectionDate,
    required this.estWeight,
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
                    Icons.recycling_rounded,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Collection Details',
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

          // Waste Type Row
          _buildDetailRow(
            icon: Icons.delete_outline_rounded,
            label: 'Waste Type',
            value: wasteType,
          ),
          SizedBox(height: 12.h),

          // Collection Date Row
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Collection Date',
            value: collectionDate,
          ),
          SizedBox(height: 12.h),

          // Est. Weight Row
          _buildDetailRow(
            icon: Icons.scale_outlined,
            label: 'Est. Weight',
            value: estWeight,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
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
