import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:suchigo_user_app/features/settings/view/about_app_screen.dart';
import 'package:suchigo_user_app/features/settings/view/help_support_screen.dart';
import 'package:suchigo_user_app/features/settings/view/privacy_security_screen.dart';
import 'package:suchigo_user_app/helpers/logout_helper.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEFAF0),
      child: Column(
        children: [
          // Top Curved Green Header
          _buildHeader(context),

          // Scrollable Menu Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                children: [
                  // Main Settings Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 12.h,
                    ),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: Icons.lock_outline_rounded,
                          title: 'Privacy & Security',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PrivacySecurityScreen.routeName,
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              HelpSupportScreen.routeName,
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.info_outline_rounded,
                          title: 'About App',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AboutAppScreen.routeName,
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.logout_rounded,
                          title: 'Logout',
                          isDestructive: true,
                          onTap: () {
                            LogoutHelper.showLogoutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E824C),
            Color(0xFF2E945D),
            Color(0xFF38A169),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(36.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF166534).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Translucent Circles
          Positioned(
            top: 20.h,
            left: 30.w,
            child: _buildCircle(65.w),
          ),
          Positioned(
            top: 30.h,
            right: 40.w,
            child: _buildCircle(50.w),
          ),
          Positioned(
            bottom: 40.h,
            left: 20.w,
            child: _buildCircle(70.w),
          ),
          Positioned(
            bottom: 30.h,
            right: 60.w,
            child: _buildCircle(80.w),
          ),

          // Header Title
          SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final iconColor =
        isDestructive ? const Color(0xFFE53935) : const Color(0xFF1D723B);
    final textColor =
        isDestructive ? const Color(0xFFE53935) : const Color(0xFF1E293B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 22.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF94A3B8),
              size: 22.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Divider(
        height: 1,
        thickness: 1,
        color: const Color(0xFFF1F5F9),
      ),
    );
  }
}
