import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_user_app/features/bills/view/bills_received_screen.dart';
import 'package:suchigo_user_app/features/orders/view/order_history_screen.dart';
import 'package:suchigo_user_app/features/wallet/view/wallet_screen.dart';

class ProfileView extends StatelessWidget {
  final String userName;
  final String phoneNumber;
  final String genderSymbol;
  final int bagsRecycled;
  final String walletBalance;

  const ProfileView({
    super.key,
    this.userName = 'User',
    this.phoneNumber = '+917592964952',
    this.genderSymbol = '♀',
    this.bagsRecycled = 0,
    this.walletBalance = '₹0.00',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F8F4),
      child: Column(
        children: [
          // Top Curved Green Profile Header
          _buildHeader(context),

          // Scrollable Profile Stats & Menu Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                children: [
                  // Top Stats Card (Bags Recycled & Wallet Balance)
                  _buildStatsCard(),

                  SizedBox(height: 16.h),

                  // Main Menu Card
                  _buildMenuCard(context),

                  SizedBox(height: 20.h),
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
            top: 25.h,
            right: 40.w,
            child: _buildCircle(55.w),
          ),
          Positioned(
            bottom: 30.h,
            left: 20.w,
            child: _buildCircle(70.w),
          ),
          Positioned(
            bottom: 20.h,
            right: 60.w,
            child: _buildCircle(80.w),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 24.h),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar Circle Badge
                    Container(
                      width: 86.w,
                      height: 86.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // User Name
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Gender Icon / Symbol
                    Text(
                      genderSymbol,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Phone Number
                    Text(
                      phoneNumber,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
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

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // Left: Bags Recycled
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco_rounded,
                  color: const Color(0xFF166534),
                  size: 24.sp,
                ),
                SizedBox(height: 6.h),
                Text(
                  'Bags Recycled',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$bagsRecycled',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1.0,
            height: 52.h,
            color: const Color(0xFFE2E8F0),
          ),

          // Right: Wallet Balance
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: const Color(0xFF166534),
                  size: 24.sp,
                ),
                SizedBox(height: 6.h),
                Text(
                  'Wallet Balance',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  walletBalance,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return Container(
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
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'SuchiGo Wallet',
            onTap: () {
              Navigator.pushNamed(context, WalletScreen.routeName);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.history_rounded,
            title: 'Order History',
            onTap: () {
              Navigator.pushNamed(context, OrderHistoryScreen.routeName);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'Bills Received',
            onTap: () {
              Navigator.pushNamed(context, BillsReceivedScreen.routeName);
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Account',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.phone_outlined,
            title: 'Contact Us',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 6.w),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF166534),
              size: 22.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
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
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Divider(
        height: 1,
        thickness: 1,
        color: const Color(0xFFF1F5F9),
      ),
    );
  }
}
