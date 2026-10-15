import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/rewards_model.dart';

class EcoVoucherCard extends StatelessWidget {
  final EcoVoucherModel voucher;
  final int userPoints;

  const EcoVoucherCard({
    super.key,
    required this.voucher,
    required this.userPoints,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = voucher.isUnlocked(userPoints);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Voucher Info Row
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lock / Gift Icon Badge
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isUnlocked
                          ? Icons.redeem_rounded
                          : Icons.lock_outline_rounded,
                      color: isUnlocked
                          ? const Color(0xFF166534)
                          : const Color(0xFF94A3B8),
                      size: 22.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),

                // Voucher Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.title,
                        style: TextStyle(
                          fontSize: 15.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        voucher.description,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF94A3B8),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF8FAFC),
          ),

          // Bottom Status Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isUnlocked ? 'Unlocked' : 'Locked',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? const Color(0xFF166534)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? const Color(0xFF166534)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isUnlocked
                        ? 'Claim Voucher'
                        : 'Requires ${voucher.requiredPoints} pts',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked
                          ? Colors.white
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
