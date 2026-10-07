import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/home_model.dart';

class WasteCategoryList extends StatelessWidget {
  final List<WasteCategoryModel> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onSelectCategory;

  const WasteCategoryList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((cat) {
        final isSelected = cat.id == selectedCategoryId;

        return InkWell(
          onTap: () => onSelectCategory(cat.id),
          borderRadius: BorderRadius.circular(16.r),
          child: SizedBox(
            width: 62.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circular Icon Badge
                Container(
                  width: 54.w,
                  height: 54.w,
                  decoration: BoxDecoration(
                    color: cat.bgColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF166534)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _buildCategoryIcon(cat),
                  ),
                ),
                SizedBox(height: 8.h),

                // Label Text
                Text(
                  cat.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: const Color(0xFF1E293B),
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryIcon(WasteCategoryModel cat) {
    if (cat.isHazardous) {
      return SizedBox(
        width: 28.w,
        height: 28.w,
        child: CustomPaint(
          painter: _HazardIconPainter(),
        ),
      );
    }

    if (cat.id == 'recycle') {
      return Icon(
        Icons.autorenew_rounded,
        color: cat.iconColor,
        size: 28.sp,
      );
    }

    if (cat.id == 'general') {
      return Icon(
        Icons.delete_outline_rounded,
        color: cat.iconColor,
        size: 26.sp,
      );
    }

    if (cat.id == 'food_waste') {
      return Icon(
        Icons.layers_outlined,
        color: cat.iconColor,
        size: 26.sp,
      );
    }

    return Icon(
      cat.icon ?? Icons.category_outlined,
      color: cat.iconColor,
      size: 26.sp,
    );
  }
}

class _HazardIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Small black center circle
    canvas.drawCircle(
      center,
      3.2,
      Paint()..color = const Color(0xFF1E293B),
    );

    // 3 trefoil fans
    for (int i = 0; i < 3; i++) {
      final startAngle = (i * 120 - 30) * math.pi / 180;
      const sweepAngle = 60 * math.pi / 180;

      final bladePath = Path();
      bladePath.arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.9),
        startAngle,
        sweepAngle,
        false,
      );
      bladePath.arcTo(
        Rect.fromCircle(center: center, radius: radius * 0.35),
        startAngle + sweepAngle,
        -sweepAngle,
        false,
      );
      bladePath.close();

      canvas.drawPath(
        bladePath,
        Paint()..color = const Color(0xFF1E293B),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
