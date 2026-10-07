import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/waste_details_model.dart';

class SegmentedTabBar extends StatelessWidget {
  final WastePropertyType selectedType;
  final ValueChanged<WastePropertyType> onChanged;

  const SegmentedTabBar({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFC3E2CD),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: 'Residential',
              type: WastePropertyType.residential,
              isSelected: selectedType == WastePropertyType.residential,
            ),
          ),
          Expanded(
            child: _buildTabItem(
              title: 'Commercial',
              type: WastePropertyType.commercial,
              isSelected: selectedType == WastePropertyType.commercial,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required WastePropertyType type,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => onChanged(type),
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? const Color(0xFF166534)
                  : const Color(0xFF536D5A),
            ),
          ),
        ),
      ),
    );
  }
}
