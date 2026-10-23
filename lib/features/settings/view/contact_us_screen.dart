import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_user_app/helpers/sp_helper.dart';
import 'package:suchigo_user_app/utils/sp_keys.dart' as sp_keys;
import 'package:suchigo_user_app/widgets/custom_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  static const routeName = '/ContactUsScreen';

  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String _userName = 'Shilpa New';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedInquiry = 'General Inquiry';
  final List<String> _inquiryOptions = [
    'General Inquiry',
    'Pickup Issue',
    'Payment & Billing',
    'Feedback & Suggestion',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final cachedName = await SpHelper.getString(sp_keys.keyUserName);
    final cachedPhone = await SpHelper.getString(sp_keys.keyUseMobile);
    final cachedEmail = await SpHelper.getString(sp_keys.keyEmail);

    if (mounted) {
      setState(() {
        if (cachedName != null && cachedName.trim().isNotEmpty) {
          _userName = cachedName.trim();
        }
        _nameController.text = _userName;
        if (cachedPhone != null && cachedPhone.trim().isNotEmpty) {
          var phone = cachedPhone.trim();
          if (phone.startsWith('+91')) {
            phone = phone.substring(3).trim();
          } else if (phone.startsWith('91') && phone.length > 10) {
            phone = phone.substring(2).trim();
          } else if (phone.startsWith('+')) {
            phone = phone.substring(1).trim();
          }
          _phoneController.text = phone;
        }
        if (cachedEmail != null && cachedEmail.trim().isNotEmpty) {
          _emailController.text = cachedEmail.trim();
        }
      });
    }
  }

  Future<void> _makeCall(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    try {
      final launched = await launchUrl(launchUri);
      if (!launched) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        await Clipboard.setData(ClipboardData(text: phone));
        if (mounted) {
          CustomToast.show(
            context,
            message: 'Phone number copied: $phone',
            icon: Icons.check_circle_outline_rounded,
          );
        }
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri mailtoUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent('Inquiry - SuchiGo Support')}',
    );
    try {
      final launched = await launchUrl(
        mailtoUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(Uri.parse('mailto:$email'));
      }
    } catch (_) {
      try {
        await launchUrl(Uri.parse('mailto:$email'));
      } catch (e) {
        await Clipboard.setData(ClipboardData(text: email));
        if (mounted) {
          CustomToast.show(
            context,
            message: 'Email address copied: $email',
            icon: Icons.mail_outline_rounded,
          );
        }
      }
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri whatsappAppUri = Uri.parse(
      'whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent('Hello SuchiGo Support, I would like to inquire about your services.')}',
    );
    final Uri whatsappWebUri = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent('Hello SuchiGo Support, I would like to inquire about your services.')}',
    );

    try {
      if (await canLaunchUrl(whatsappAppUri)) {
        await launchUrl(whatsappAppUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    try {
      final launched = await launchUrl(
        whatsappWebUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(
          whatsappWebUri,
          mode: LaunchMode.inAppBrowserView,
        );
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: '+$cleanPhone'));
      if (mounted) {
        CustomToast.show(
          context,
          message: 'WhatsApp number copied: +$cleanPhone',
          icon: Icons.check_circle_outline_rounded,
        );
      }
    }
  }

  void _openOfficeLocation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _buildOfficeDetailsSheet(),
    );
  }

  Future<void> _launchMapsUrl(String query) async {
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    final Uri geoUri = Uri.parse('geo:0,0?q=${Uri.encodeComponent(query)}');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    try {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          context,
          message: 'Unable to open maps',
        );
      }
    }
  }

  Widget _buildOfficeDetailsSheet() {
    const fullAddress =
        'SuchiGo Corporate Office, Civil Station Road, Kakkanad, Ernakulam, Kerala – 682030';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFF57C00),
                      size: 26,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our Office',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Ernakulam Headquarters',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Office Address',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    fullAddress,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  SizedBox(height: 12.h),
                  Text(
                    'Office Phone',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _makeCall('+918111882244');
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 16.sp,
                          color: const Color(0xFF166534),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '+91 8111882244',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 46.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                _makeCall('+918111882244');
              },
              icon: const Icon(
                Icons.phone_rounded,
                size: 20,
                color: Colors.white,
              ),
              label: Text(
                'Call Office (+91 8111882244)',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: fullAddress),
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        CustomToast.show(
                          context,
                          message: 'Address copied to clipboard',
                          icon: Icons.check_circle_outline_rounded,
                          iconColor: const Color(0xFF166534),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: Color(0xFF475569),
                    ),
                    label: Text(
                      'Copy Address',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _launchMapsUrl(fullAddress);
                    },
                    icon: const Icon(
                      Icons.directions_rounded,
                      size: 20,
                      color: Color(0xFF166534),
                    ),
                    label: Text(
                      'View in Maps',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final Uri launchUri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(launchUri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      if (mounted) {
        CustomToast.show(context, message: 'Could not open link');
      }
    }
  }

  void _sendMessage() {
    final name = _nameController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty) {
      CustomToast.show(context, message: 'Please enter your name');
      return;
    }
    if (message.isEmpty) {
      CustomToast.show(context, message: 'Please write your message');
      return;
    }

    _subjectController.clear();
    _messageController.clear();

    CustomToast.show(
      context,
      message: 'Message sent successfully! Our team will contact you soon.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Green Curved Header with Title & Welcome Card
            _buildHeader(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2x2 Quick Contact Grid
                  _buildQuickContactGrid(),
                  SizedBox(height: 14.h),

                  // Office Hours Green Banner
                  _buildOfficeHoursBanner(),
                  SizedBox(height: 20.h),

                  // "Send Us a Message" Form
                  _buildMessageForm(),
                  SizedBox(height: 22.h),

                  // "Follow Us" Section
                  _buildFollowUsSection(),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2EB872),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D723B).withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar: Back Button & Title
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 4.h),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(22.r),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Contact Us',
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w), // Balance back button
                ],
              ),
            ),
            SizedBox(height: 10.h),

            // White Welcome Card
            Container(
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Welcome back, $_userName! 👋',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Manage your waste collection and track your environmental impact',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickContactGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                icon: Icons.phone_rounded,
                iconColor: const Color(0xFF1976D2),
                iconBgColor: const Color(0xFFE3F2FD),
                title: 'Call Us',
                subtitle: '+91 8111882244',
                onTap: () => _makeCall('+918111882244'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildContactCard(
                icon: Icons.mail_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBgColor: const Color(0xFFE8F5E9),
                title: 'Email Us',
                subtitle: 'support@suchigo.com',
                onTap: () => _sendEmail('support@suchigo.com'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                icon: Icons.chat_bubble_rounded,
                iconColor: const Color(0xFF2E7D32),
                iconBgColor: const Color(0xFFE8F5E9),
                title: 'WhatsApp',
                subtitle: '+91 8111882244',
                onTap: () => _openWhatsApp('918111882244'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildContactCard(
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFFF57C00),
                iconBgColor: const Color(0xFFFFF3E0),
                title: 'Our Office',
                subtitle: 'Ernakulam, Kerala',
                onTap: _openOfficeLocation,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 22.sp,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
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

  Widget _buildOfficeHoursBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1D723B),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D723B).withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: const Center(
              child: Icon(
                Icons.access_time_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Office Hours',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Mon – Sat: 8:00 AM – 6:00 PM',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
                Text(
                  'Sunday: Closed',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send Us a Message',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 12.h),

        // Name field
        _buildInputField(
          controller: _nameController,
          icon: Icons.person_outline_rounded,
          hintText: 'Your Name',
        ),
        SizedBox(height: 12.h),

        // Phone field
        _buildInputField(
          controller: _phoneController,
          icon: Icons.phone_outlined,
          hintText: 'Phone Number',
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 12.h),

        // Email field
        _buildInputField(
          controller: _emailController,
          icon: Icons.mail_outline_rounded,
          hintText: 'Email Address',
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 12.h),

        // Inquiry Dropdown
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedInquiry,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8),
              ),
              items: _inquiryOptions.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Row(
                    children: [
                      Icon(
                        Icons.interests_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        opt,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedInquiry = val);
                }
              },
            ),
          ),
        ),
        SizedBox(height: 12.h),

        // Subject field
        _buildInputField(
          controller: _subjectController,
          icon: Icons.subject_rounded,
          hintText: 'Subject',
        ),
        SizedBox(height: 12.h),

        // Multiline Message field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 4,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: 'Write your message here...',
              hintStyle: TextStyle(
                fontSize: 13.5.sp,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 50.h),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 20.sp,
                ),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14.w),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // SEND MESSAGE Action Button
        InkWell(
          onTap: _sendMessage,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1D723B),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D723B).withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'SEND MESSAGE',
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 13.5.sp,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF94A3B8),
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildFollowUsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow Us',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSocialItem(
              icon: Icons.facebook_rounded,
              label: 'Facebook',
              color: const Color(0xFF1877F2),
              bgColor: const Color(0xFFE3F2FD),
              onTap: () => _openUrl('https://facebook.com'),
            ),
            _buildSocialItem(
              icon: Icons.alternate_email_rounded,
              label: 'Twitter',
              color: const Color(0xFF00ACC1),
              bgColor: const Color(0xFFE0F7FA),
              onTap: () => _openUrl('https://twitter.com'),
            ),
            _buildSocialItem(
              icon: Icons.camera_alt_rounded,
              label: 'Instagram',
              color: const Color(0xFFE91E63),
              bgColor: const Color(0xFFFCE4EC),
              onTap: () => _openUrl('https://instagram.com'),
            ),
            _buildSocialItem(
              icon: Icons.play_circle_fill_rounded,
              label: 'YouTube',
              color: const Color(0xFFD32F2F),
              bgColor: const Color(0xFFFFEBEE),
              onTap: () => _openUrl('https://youtube.com'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
