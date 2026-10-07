import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_user_app/features/auth/view/auth_screen.dart';
import '../view_model/onboarding_view_model.dart';
import 'widgets/onboarding_indicator.dart';
import 'widgets/onboarding_slider_item.dart';

class OnboardingScreen extends StatefulWidget {
  static const routeName = '/OnboardingScreen';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late OnboardingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OnboardingViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<OnboardingViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF166534),
                ),
              );
            }

            final currentSlide = vm.slides.isNotEmpty
                ? vm.slides[vm.currentIndex]
                : null;

            return Stack(
              children: [
                // Full screen onboarding slide images
                Positioned.fill(
                  child: PageView.builder(
                    controller: vm.pageController,
                    itemCount: vm.totalSlides,
                    onPageChanged: vm.onPageChanged,
                    itemBuilder: (context, index) {
                      return OnboardingSliderItem(
                        model: vm.slides[index],
                      );
                    },
                  ),
                ),

                // Main Overlay Controls (Skip & Bottom Navigation)
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Bar with Skip Button
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              vm.skipToLast();
                            },
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 18.w,
                                vertical: 7.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1B6B38),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Bottom Navigation Row (Indicator & Next/Get Started Button)
                      Padding(
                        padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Indicators
                            OnboardingIndicator(
                              totalCount: vm.totalSlides,
                              currentIndex: vm.currentIndex,
                            ),

                            // Next / Get Started Pill Button
                            InkWell(
                              onTap: () {
                                vm.nextPage(
                                  onComplete: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AuthScreen.routeName,
                                    );
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(25.r),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: EdgeInsets.symmetric(
                                  horizontal: vm.isLastSlide ? 24.w : 22.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF166534),
                                  borderRadius: BorderRadius.circular(25.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF166534)
                                          .withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currentSlide?.buttonText ?? 'Next',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    const Icon(
                                      Icons.east_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
