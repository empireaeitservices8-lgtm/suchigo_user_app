import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactInfoCard extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController contactNumberController;
  final TextEditingController emailController;

  const ContactInfoCard({
    super.key,
    required this.fullNameController,
    required this.contactNumberController,
    required this.emailController,
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
          // Header
          Row(
            children: [
              const Icon(
                Icons.person_rounded,
                color: Color(0xFF166534),
                size: 20,
              ),
              SizedBox(width: 8.w),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Full Name Field
          _buildFieldLabel('Full Name', isRequired: true),
          SizedBox(height: 6.h),
          _buildInputField(
            controller: fullNameController,
            hint: 'Enter your full name',
          ),
          SizedBox(height: 16.h),

          // Contact Number Field
          _buildFieldLabel('Contact Number', isRequired: true),
          SizedBox(height: 6.h),
          _buildInputField(
            controller: contactNumberController,
            hint: 'Enter contact number',
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 16.h),

          // Email Address Field
          _buildFieldLabel('Email Address (Optional)', isRequired: false),
          SizedBox(height: 6.h),
          _buildInputField(
            controller: emailController,
            hint: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          if (isRequired)
            TextSpan(
              text: ' *',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFEF4444),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFB0BEC5),
          ),
          filled: false,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
