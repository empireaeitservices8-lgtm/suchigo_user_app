import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/waste_details_model.dart';

class WasteTypeCard extends StatelessWidget {
  final WasteCategoryDetailModel model;
  final bool isSelected;
  final VoidCallback onTap;

  const WasteTypeCard({
    super.key,
    required this.model,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = model.isEnabled;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.55,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF166534)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF166534).withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon in soft mint circle
              Container(
                width: 48.w,
                height: 48.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F6EF),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    model.icon,
                    color: const Color(0xFF166534),
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(height: 10.h),

              // Title
              Text(
                model.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 5.h),

              // Description
              Text(
                model.description,
                textAlign: TextAlign.center,
                maxLines: 3,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
