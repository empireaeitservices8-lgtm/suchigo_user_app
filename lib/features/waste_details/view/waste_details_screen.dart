import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_user_app/features/home/view/widgets/bottom_nav_bar.dart';
import '../view_model/waste_details_view_model.dart';
import 'widgets/segmented_tab_bar.dart';
import 'widgets/sub_waste_rate_card.dart';
import 'widgets/waste_type_card.dart';

class WasteDetailsScreen extends StatefulWidget {
  static const routeName = '/WasteDetailsScreen';
  final String? initialCategoryId;

  const WasteDetailsScreen({
    super.key,
    this.initialCategoryId,
  });

  @override
  State<WasteDetailsScreen> createState() => _WasteDetailsScreenState();
}

class _WasteDetailsScreenState extends State<WasteDetailsScreen> {
  late WasteDetailsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = WasteDetailsViewModel(
      initialCategoryId: widget.initialCategoryId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F8F4),
        body: Consumer<WasteDetailsViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.h),
                          // Back Button
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF1E293B),
                              size: 26,
                            ),
                          ),
                          SizedBox(height: 4.h),

                          // Header Title & Subtitle
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'WASTE DETAILS',
                                  style: TextStyle(
                                    fontSize: 26.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF166534),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "Help us understand what you're disposing of so we can\ncome prepared.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF78909C),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Residential / Commercial Segmented Control
                          SegmentedTabBar(
                            selectedType: vm.propertyType,
                            onChanged: (type) => vm.setPropertyType(type),
                          ),
                          SizedBox(height: 20.h),

                          // 2x2 Waste Categories Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                              childAspectRatio: 0.95,
                            ),
                            itemCount: vm.categories.length,
                            itemBuilder: (context, index) {
                              final cat = vm.categories[index];
                              final isSelected =
                                  vm.selectedCategoryId == cat.id;

                              return WasteTypeCard(
                                model: cat,
                                isSelected: isSelected,
                                onTap: () => vm.selectCategory(cat.id),
                              );
                            },
                          ),
                          SizedBox(height: 28.h),

                          // Sub-Waste Rates & Pricing Section Header
                          Text(
                            'SUB-WASTE RATES & PRICING',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF166534),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 14.h),

                          // Sub-waste Rates List
                          if (vm.subWasteRates.isNotEmpty)
                            ...vm.subWasteRates.map(
                              (rate) => Padding(
                                padding: EdgeInsets.only(bottom: 14.h),
                                child: SubWasteRateCard(model: rate),
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Center(
                                child: Text(
                                  'Select a waste category to view pricing',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 18.h),

                          // Continue Action Button
                          Center(
                            child: InkWell(
                              onTap: vm.canContinue
                                  ? () {
                                      Navigator.pushNamed(
                                        context,
                                        '/SchedulePickupScreen',
                                      );
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(28.r),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 220.w,
                                height: 50.h,
                                decoration: BoxDecoration(
                                  color: vm.canContinue
                                      ? const Color(0xFF166534)
                                      : const Color(0xFFA8D5BA)
                                          .withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(28.r),
                                  boxShadow: vm.canContinue
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF166534)
                                                .withValues(alpha: 0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Continue',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: vm.canContinue
                                            ? Colors.white
                                            : const Color(0xFF166534)
                                                .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(
                                      Icons.east_rounded,
                                      color: vm.canContinue
                                          ? Colors.white
                                          : const Color(0xFF166534)
                                              .withValues(alpha: 0.6),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Navigation Bar
                CustomBottomNavBar(
                  currentIndex: vm.bottomNavIndex,
                  onTap: (index) {
                    vm.setBottomNavIndex(index);
                    if (index == 0) {
                      Navigator.pop(context);
                    }
                  },
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
