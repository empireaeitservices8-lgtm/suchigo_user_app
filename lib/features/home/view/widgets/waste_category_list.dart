import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../model/home_model.dart';

class WasteCategoryList extends StatelessWidget {
  final List<WasteCategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onSelectCategory;

  const WasteCategoryList({
    super.key,
    required this.categories,
    this.selectedCategoryId,
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
          borderRadius: BorderRadius.circular(20.r),
          child: SizedBox(
            width: 64.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rounded Card Badge
                Container(
                  width: 58.w,
                  height: 58.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: isSelected
                        ? Border.all(
                            color: const Color(0xFF166534),
                            width: 2.0,
                          )
                        : Border.all(
                            color: const Color(0xFFF1F5F9),
                            width: 1.0,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _buildCategoryIcon(cat),
                  ),
                ),
                SizedBox(height: 8.h),

                // Label Text
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    cat.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      height: 1.15,
                    ),
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
    if (cat.isHazardous || cat.id == 'hazardous') {
      return Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          color: Color(0xFFFFC82C),
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(6.5.w),
        child: Center(
          child: SvgPicture.asset(
            'assets/svgs/biohazard.svg',
            colorFilter: const ColorFilter.mode(
              Color(0xFF1A1A1A),
              BlendMode.srcIn,
            ),
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    if (cat.id == 'general') {
      return SvgPicture.asset(
        'assets/svgs/waste_general.svg',
        width: 28.w,
        height: 28.w,
        fit: BoxFit.contain,
      );
    }

    if (cat.id == 'recycle') {
      return Icon(
        Icons.recycling,
        color: const Color(0xFF2196F3),
        size: 32.sp,
      );
    }

    if (cat.id == 'food_waste') {
      return SvgPicture.asset(
        'assets/svgs/waste_food.svg',
        width: 28.w,
        height: 28.w,
        fit: BoxFit.contain,
      );
    }

    if (cat.id == 'e_waste') {
      return SvgPicture.asset(
        'assets/svgs/waste_electronic.svg',
        width: 29.w,
        height: 29.w,
        fit: BoxFit.contain,
      );
    }

    return Icon(
      cat.icon ?? Icons.category_outlined,
      color: cat.iconColor,
      size: 26.sp,
    );
  }
}

