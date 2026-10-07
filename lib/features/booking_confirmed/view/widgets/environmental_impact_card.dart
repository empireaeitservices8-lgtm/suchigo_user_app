import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EnvironmentalImpactCard extends StatelessWidget {
  final String co2Saved;
  final String recycledPercent;
  final String treesEquiv;

  const EnvironmentalImpactCard({
    super.key,
    required this.co2Saved,
    required this.recycledPercent,
    required this.treesEquiv,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E6B38),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E6B38).withValues(alpha: 0.25),
            blurRadius: 12,
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
              const Icon(
                Icons.eco_rounded,
                color: Color(0xFF81C784),
                size: 20,
              ),
              SizedBox(width: 8.w),
              Text(
                'Your Environmental Impact',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // 3 Columns Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. CO2 Saved
              _buildStatColumn(
                icon: const Icon(
                  Icons.spa_rounded,
                  color: Color(0xFFA5D6A7),
                  size: 26,
                ),
                value: co2Saved,
                label: 'CO₂ Saved',
              ),

              // 2. Recycled
              _buildStatColumn(
                icon: const Icon(
                  Icons.recycling_rounded,
                  color: Color(0xFFA5D6A7),
                  size: 26,
                ),
                value: recycledPercent,
                label: 'Recycled',
              ),

              // 3. Trees Equiv
              _buildStatColumn(
                icon: const Icon(
                  Icons.public_rounded,
                  color: Color(0xFF64B5F6),
                  size: 26,
                ),
                value: treesEquiv,
                label: 'Trees Equiv.',
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Footer Message
          Center(
            child: Text(
              'Thank you for contributing to a greener planet! 🌿',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFC8E6C9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required Widget icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFA5D6A7),
          ),
        ),
      ],
    );
  }
}
