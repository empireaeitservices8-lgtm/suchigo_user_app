import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_user_app/services/network_service.dart';
import 'package:suchigo_user_app/widgets/app_button_widget.dart';

class ConnectionFailedScreenParams {
  /// The function in which the failed API is called
  final Function? failedAPI;

  /// If want to perform anything while trying to recall
  final VoidCallback? onRetry;

  /// Should retry automatically on connection restored?
  final bool autoRetry;

  ConnectionFailedScreenParams({
    this.failedAPI,
    this.onRetry,
    this.autoRetry = true,
  });
}

class ConnectionFailedScreen extends StatefulWidget {
  static const String routeName = '/ConnectionFailedScreen';
  final ConnectionFailedScreenParams param;
  const ConnectionFailedScreen({super.key, required this.param});

  @override
  State<ConnectionFailedScreen> createState() => _ConnectionFailedScreenState();
}

class _ConnectionFailedScreenState extends State<ConnectionFailedScreen> {
  final ValueNotifier<bool> loadingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    NetworkService.instance.addListener(_onNetworkChange);
  }

  void _onNetworkChange() async {
    if (NetworkService.instance.isOnline) {
      if (widget.param.autoRetry) {
        _triggerRetry();
      }
    }
  }

  Future<void> _triggerRetry() async {
    try {
      loadingNotifier.value = true;
      if (widget.param.onRetry != null) {
        widget.param.onRetry!();
      }
      if (widget.param.failedAPI != null) {
        await widget.param.failedAPI!();
      }
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      log('Retry error: $e');
    } finally {
      if (mounted) {
        loadingNotifier.value = false;
      }
    }
  }

  @override
  void dispose() {
    NetworkService.instance.removeListener(_onNetworkChange);
    loadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1E293B),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: loadingNotifier,
          builder: (context, isLoading, _) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration Circle
                    Container(
                      width: 110.w,
                      height: 110.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.wifi_off_rounded,
                          color: const Color(0xFFDC2626),
                          size: 52.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 28.h),

                    // Title
                    Text(
                      'No Internet Connection',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.h),

                    // Description
                    Text(
                      'Your device is currently offline. Please check your Wi-Fi or mobile data network. We will automatically reconnect once you are back online.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 36.h),

                    // Try Again Button
                    AppButton(
                      text: 'Try Again',
                      isLoading: isLoading,
                      onTap: () async {
                        final hasNet = await NetworkService.instance.checkConnection();
                        if (hasNet) {
                          await _triggerRetry();
                        } else {
                          // Artificial delay for tactile feedback if still offline
                          loadingNotifier.value = true;
                          await Future.delayed(const Duration(milliseconds: 600));
                          if (mounted) {
                            loadingNotifier.value = false;
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
