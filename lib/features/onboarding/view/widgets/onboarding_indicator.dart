import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingIndicator extends StatelessWidget {
  final int totalCount;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  const OnboardingIndicator({
    super.key,
    required this.totalCount,
    required this.currentIndex,
    this.activeColor = const Color(0xFF1B6B38),
    this.inactiveColor = const Color(0xFFE2E8F0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(right: 6.w),
          width: isActive ? 26.w : 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
