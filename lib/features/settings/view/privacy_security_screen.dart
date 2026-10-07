import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrivacySecurityScreen extends StatefulWidget {
  static const routeName = '/PrivacySecurityScreen';

  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  // Track expanded index for accordions
  int? _expandedIndex;

  final List<Map<String, dynamic>> _privacyItems = [
    {
      'icon': Icons.shield_rounded,
      'title': 'Data Protection & Encryption',
      'content':
          'All your personal data, transaction records, and communication are encrypted end-to-end using AES-256 and SSL/TLS standards. We strictly adhere to industry safety protocols and never store unencrypted sensitive information on our servers.',
    },
    {
      'icon': Icons.location_on_rounded,
      'title': 'Location Data Usage',
      'content':
          'Your location is used solely to pinpoint pickup addresses accurately and enable live tracking of collection vehicles. We never share or sell real-time GPS coordinates to any unauthorized third parties.',
    },
    {
      'icon': Icons.manage_accounts_rounded,
      'title': 'Personal Information Sharing',
      'content':
          'We do not sell your personal profile data. Minimal contact information (name, address, phone number) is shared strictly with the assigned sanitation collector to fulfill your pickup service.',
    },
    {
      'icon': Icons.delete_rounded,
      'title': 'Account & Data Deletion',
      'content':
          'You have complete ownership of your personal data. You can request permanent deletion of your profile and past pickup logs at any time by contacting our support team or visiting account settings.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D723B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy & Security',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Green Status Banner Card
            _buildSecureConnectionBanner(),
            SizedBox(height: 22.h),

            // Section Heading
            Text(
              'Privacy Policies & Info',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 14.h),

            // Policy Accordion List
            ...List.generate(_privacyItems.length, (index) {
              final item = _privacyItems[index];
              final isExpanded = _expandedIndex == index;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildPolicyAccordionItem(
                  index: index,
                  icon: item['icon'] as IconData,
                  title: item['title'] as String,
                  content: item['content'] as String,
                  isExpanded: isExpanded,
                ),
              );
            }),

            SizedBox(height: 12.h),

            // Bottom Security Tips Card
            _buildSecurityTipsCard(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSecureConnectionBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1D723B),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D723B).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular shield check icon
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: const Color(0xFF4BB14E).withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 14.w),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your connection is secure',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'App version 1.0.0 is secured with industry-grade security protocols.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyAccordionItem({
    required int index,
    required IconData icon,
    required String title,
    required String content,
    required bool isExpanded,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: const Color(0xFF1D723B),
                      size: 22.sp,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 24.sp,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  SizedBox(height: 10.h),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  SizedBox(height: 10.h),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF64748B),
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTipsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFFDE68A),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: const Color(0xFFD97706),
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Security Tips',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildTipBullet(
            'Never share your verification OTP with anyone, including SuchiGo agents.',
          ),
          SizedBox(height: 8.h),
          _buildTipBullet(
            'Ensure your mobile device has a screen lock enabled for data protection.',
          ),
          SizedBox(height: 8.h),
          _buildTipBullet(
            'Verify the identity of the collector at your doorstep using the track map.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFD97706),
            height: 1.35,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD97706),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
