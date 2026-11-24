import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_user_app/services/network_service.dart';

/// Global overlay widget wrapped around the application's root.
/// Automatically displays a sleek animated banner when offline,
/// and a brief "Back Online" confirmation when connectivity is restored.
class NetworkBannerOverlay extends StatefulWidget {
  final Widget child;

  const NetworkBannerOverlay({super.key, required this.child});

  @override
  State<NetworkBannerOverlay> createState() => _NetworkBannerOverlayState();
}

class _NetworkBannerOverlayState extends State<NetworkBannerOverlay> {
  bool _showBackOnline = false;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    NetworkService.instance.addListener(_handleNetworkChange);
  }

  @override
  void dispose() {
    NetworkService.instance.removeListener(_handleNetworkChange);
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _handleNetworkChange() {
    final isOnline = NetworkService.instance.isOnline;
    if (isOnline && NetworkService.instance.wasOffline) {
      if (mounted) {
        setState(() {
          _showBackOnline = true;
        });
      }
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showBackOnline = false;
          });
        }
      });
    } else if (!isOnline) {
      _dismissTimer?.cancel();
      if (mounted) {
        setState(() {
          _showBackOnline = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NetworkService.instance,
      builder: (context, _) {
        final isOnline = NetworkService.instance.isOnline;
        final isVisible = !isOnline || _showBackOnline;

        final isBackOnline = isOnline && _showBackOnline;
        final bgColor = isBackOnline
            ? const Color(0xFF166534) // Emerald green
            : const Color(0xFFB91C1C); // Deep red
        final icon = isBackOnline
            ? Icons.wifi_rounded
            : Icons.wifi_off_rounded;
        final title = isBackOnline
            ? 'Back Online'
            : 'No Internet Connection';
        final subtitle = isBackOnline
            ? 'Connected to the internet'
            : 'Check your Wi-Fi or mobile data';

        return Stack(
          children: [
            widget.child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: !isVisible,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  offset: isVisible ? Offset.zero : const Offset(0, -1.3),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 260),
                    opacity: isVisible ? 1.0 : 0.0,
                    child: Material(
                      type: MaterialType.transparency,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(7.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    icon,
                                    color: Colors.white,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5.sp,
                                          fontWeight: FontWeight.w800,
                                          decoration: TextDecoration.none,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        subtitle,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.88),
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isOnline) ...[
                                  SizedBox(width: 8.w),
                                  InkWell(
                                    onTap: () {
                                      NetworkService.instance.checkConnection();
                                    },
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                      ),
                                      child: Text(
                                        'Retry',
                                        style: TextStyle(
                                          color: const Color(0xFFB91C1C),
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w800,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A standalone reusable widget for empty/error states inside screens
/// when data failed to load due to no internet connection.
class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NoInternetWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76.w,
              height: 76.w,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: const Color(0xFFDC2626),
                  size: 36.sp,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              message ??
                  'Please check your network settings and try again. We will reconnect automatically when available.',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () {
                  NetworkService.instance.checkConnection();
                  onRetry?.call();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
