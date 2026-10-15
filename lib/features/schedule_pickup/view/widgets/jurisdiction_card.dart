import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../model/schedule_pickup_model.dart';

class JurisdictionCard extends StatelessWidget {
  final JurisdictionModel jurisdiction;
  final VoidCallback onSelectDistrict;
  final VoidCallback onSelectLocalBody;
  final VoidCallback onSelectWard;

  const JurisdictionCard({
    super.key,
    required this.jurisdiction,
    required this.onSelectDistrict,
    required this.onSelectLocalBody,
    required this.onSelectWard,
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
          // District Field
          _buildDropdownRow(
            icon: Icons.landscape_outlined,
            label: 'District',
            value: jurisdiction.district,
            isSelected: jurisdiction.district != 'Not Selected',
            onTap: onSelectDistrict,
          ),
          _buildDivider(),

          // Local Body Field
          _buildDropdownRow(
            icon: Icons.location_city_outlined,
            label: 'Local Body',
            value: jurisdiction.localBody,
            badge: jurisdiction.localBody != 'Not Selected'
                ? (jurisdiction.ratePerKg != null
                    ? '₹${jurisdiction.ratePerKg!.toStringAsFixed(0)}/kg'
                    : '₹40/kg')
                : null,
            isSelected: jurisdiction.localBody != 'Not Selected',
            onTap: onSelectLocalBody,
          ),
          _buildDivider(),

          // Ward Name & Number Field
          _buildDropdownRow(
            icon: Icons.meeting_room_outlined,
            label: 'Ward Name & Number',
            value: jurisdiction.wardNameAndNumber,
            isSelected: jurisdiction.wardNameAndNumber != 'Not Selected',
            onTap: onSelectWard,
          ),
          SizedBox(height: 16.h),

          // Bottom Rate Row
          Row(
            children: [
              const Icon(
                Icons.currency_rupee_rounded,
                color: Color(0xFFFF9800),
                size: 20,
              ),
              SizedBox(width: 8.w),
              Text(
                'Rate per KG:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: (jurisdiction.ratePerKg != null ||
                          jurisdiction.localBody != 'Not Selected')
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  jurisdiction.ratePerKg != null
                      ? '₹${jurisdiction.ratePerKg!.toStringAsFixed(2)} / kg'
                      : (jurisdiction.localBody != 'Not Selected'
                          ? '₹40.00 / kg'
                          : '--'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: (jurisdiction.ratePerKg != null ||
                            jurisdiction.localBody != 'Not Selected')
                        ? const Color(0xFF166534)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownRow({
    required IconData icon,
    required String label,
    required String value,
    String? badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF166534),
              size: 22,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF166534),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: const Color(0xFFF1F5F9),
      thickness: 1.0,
      height: 12.h,
    );
  }
}
