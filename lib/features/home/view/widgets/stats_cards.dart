import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _SloganItem {
  final String tag;
  final IconData icon;
  final String slogan;
  final String description;
  final String imagePath;
  final List<Color> gradientColors;
  final Color accentColor;
  final Color tagBgColor;

  const _SloganItem({
    required this.tag,
    required this.icon,
    required this.slogan,
    required this.description,
    required this.imagePath,
    required this.gradientColors,
    required this.accentColor,
    required this.tagBgColor,
  });
}

class StatsCards extends StatefulWidget {
  final int treesSaved;
  final int rewardPoints;
  final int kgGives;

  const StatsCards({
    super.key,
    this.treesSaved = 0,
    this.rewardPoints = 300,
    this.kgGives = 1,
  });

  @override
  State<StatsCards> createState() => _StatsCardsState();
}

class _StatsCardsState extends State<StatsCards> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  static const List<_SloganItem> _items = [
    _SloganItem(
      tag: 'RECYCLE SMART',
      icon: Icons.recycling_rounded,
      slogan: 'Sort Smart, Recycle Better',
      description:
          'Separate wet & dry waste to keep up to 80% out of landfills.',
      imagePath: 'assets/images/onboarding_recycle.png',
      gradientColors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
      accentColor: Color(0xFF1B5E20),
      tagBgColor: Color(0xFF2E7D32),
    ),
    _SloganItem(
      tag: 'REDUCE IMPACT',
      icon: Icons.eco_rounded,
      slogan: 'Lighter Habits, Greener Future',
      description:
          'Minimize single-use plastics & embrace sustainable reuse daily.',
      imagePath: 'assets/images/onboarding_reduce.png',
      gradientColors: [Color(0xFFE0F7FA), Color(0xFFE8F5E9)],
      accentColor: Color(0xFF00695C),
      tagBgColor: Color(0xFF00796B),
    ),
    _SloganItem(
      tag: 'REUSE & REPURPOSE',
      icon: Icons.change_circle_outlined,
      slogan: 'Give Waste A Second Life',
      description:
          'Repair, repurpose, and donate goods before sending to scrap.',
      imagePath: 'assets/images/onboarding_reuse.png',
      gradientColors: [Color(0xFFFFF8E1), Color(0xFFF1F8E9)],
      accentColor: Color(0xFFE65100),
      tagBgColor: Color(0xFFF57C00),
    ),
    _SloganItem(
      tag: 'CLEAN EARTH',
      icon: Icons.park_rounded,
      slogan: 'Planting Green, Growing Life',
      description: 'Turn organic scraps into rich compost for greener living.',
      imagePath: 'assets/images/onboarding_planting.png',
      gradientColors: [Color(0xFFF1F8E9), Color(0xFFDCEDC8)],
      accentColor: Color(0xFF33691E),
      tagBgColor: Color(0xFF558B2F),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextIndex = (_currentIndex + 1) % _items.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF166534).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: PageView.builder(
          controller: _pageController,
          itemCount: _items.length,
          onPageChanged: (idx) {
            setState(() {
              _currentIndex = idx;
            });
          },
          itemBuilder: (context, index) {
            final item = _items[index];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: item.gradientColors,
                ),
                border: Border.all(
                  color: item.accentColor.withValues(alpha: 0.15),
                  width: 1.2,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  // Left Text Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Tag Pill
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: item.tagBgColor,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                size: 11.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                item.tag,
                                style: TextStyle(
                                  fontSize: 9.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Slogan
                        Text(
                          item.slogan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w800,
                            color: item.accentColor,
                            letterSpacing: -0.2,
                          ),
                        ),

                        // Informative Tip
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF334155),
                            height: 1.25,
                          ),
                        ),

                        // Bottom Indicator Dots
                        Row(
                          children: List.generate(
                            _items.length,
                            (dotIndex) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.only(right: 5.w),
                              width: _currentIndex == dotIndex ? 16.w : 5.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: _currentIndex == dotIndex
                                    ? item.accentColor
                                    : item.accentColor.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),

                  // Right Waste Management Illustration
                  Container(
                    width: 86.w,
                    height: 106.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
