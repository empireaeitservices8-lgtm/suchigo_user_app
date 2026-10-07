import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  static const routeName = '/HelpSupportScreen';

  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedFaqIndex;

  final List<Map<String, String>> _faqList = [
    {
      'question': 'How do I schedule a waste pickup?',
      'answer':
          'Go to the Home screen and tap "Schedule Pickup", select your pickup location, choose your waste types and scheduled date/time slot, then confirm your booking.',
    },
    {
      'question': 'What types of waste are accepted?',
      'answer':
          'We collect segregated recyclable waste (plastics, paper, metals, glass), organic/biodegradable waste, electronic waste, and bulk scrap materials.',
    },
    {
      'question': 'Is there a charge for bulk collection?',
      'answer':
          'Standard domestic collections are covered under standard service charges. Commercial bulk pickups and construction debris have dedicated weight-based rates shown at checkout.',
    },
    {
      'question': 'How can I track my pickup driver?',
      'answer':
          'Once a pickup driver is dispatched, open your Order History or Booking Details screen and tap "Track Vehicle" to view live driver location and ETA.',
    },
  ];

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Helpline: $phoneNumber'),
            backgroundColor: const Color(0xFF1D723B),
          ),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email support: $email'),
            backgroundColor: const Color(0xFF1D723B),
          ),
        );
      }
    }
  }

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
          'Help & Support',
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
            // Top Green Helpline Card
            _buildHelplineCard(),
            SizedBox(height: 16.h),

            // Email Support Card
            _buildEmailCard(),
            SizedBox(height: 24.h),

            // Section Heading
            Text(
              'FAQ & Support',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 14.h),

            // FAQ Expandable List
            ...List.generate(_faqList.length, (index) {
              final item = _faqList[index];
              final isExpanded = _expandedFaqIndex == index;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildFaqItem(
                  index: index,
                  question: item['question']!,
                  answer: item['answer']!,
                  isExpanded: isExpanded,
                ),
              );
            }),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplineCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1D723B),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D723B).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF4BB14E).withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.headset_mic_rounded,
                  color: Colors.white,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Helpline (Toll-Free)',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Call our 24/7 dedicated toll-free helpline for immediate booking assistance.',
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
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1800-123-5678',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () => _makePhoneCall('18001235678'),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.call_rounded,
                        color: const Color(0xFF1D723B),
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'CALL NOW',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1D723B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _sendEmail('support@suchigo.com'),
          borderRadius: BorderRadius.circular(16.r),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  Icons.mail_outline_rounded,
                  color: const Color(0xFF1D723B),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Support',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'support@suchigo.com',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required int index,
    required String question,
    required String answer,
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
              _expandedFaqIndex = isExpanded ? null : index;
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
                      Icons.chat_bubble_outline_rounded,
                      color: const Color(0xFF1D723B),
                      size: 20.sp,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        question,
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
                    answer,
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
}
