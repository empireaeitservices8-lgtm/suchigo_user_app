import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/custom_toast.dart';
import '../view_model/home_view_model.dart';
import 'widgets/activity_card.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/home_banner.dart';
import 'widgets/home_header.dart';
import 'widgets/profile_view.dart';
import 'widgets/settings_view.dart';
import 'widgets/stats_cards.dart';
import 'widgets/waste_category_list.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/HomeScreen';
  final int initialTabIndex;

  const HomeScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(initialTabIndex: widget.initialTabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<HomeViewModel>(
          builder: (context, vm, child) {
            Widget currentContent;
            if (vm.selectedTabIndex == 1) {
              currentContent = const SettingsView();
            } else if (vm.selectedTabIndex == 2) {
              final profile = vm.dashboardData.profile;
              currentContent = ProfileView(
                profile: profile,
                bagsRecycled: profile?.numberOfBags ?? 0,
                walletBalance:
                    '₹${(profile?.walletBalance ?? 0.0).toStringAsFixed(2)}',
              );
            } else if (vm.isLoading) {
              currentContent = const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF166534),
                ),
              );
            } else {
              final data = vm.dashboardData;
              currentContent = Column(
                children: [
                  // Top Gradient App Bar / Header
                  HomeHeader(
                    userName: data.userName,
                    progress: data.userProgress,
                  ),

                  // Main Scrollable Dashboard Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        children: [
                          // Hero Banner Card
                          const HomeBanner(),
                          SizedBox(height: 20.h),

                          // Waste Categories (Hazardous, General, Recycle, Food Waste, E-Waste)
                          WasteCategoryList(
                            categories: data.categories,
                            selectedCategoryId: vm.selectedCategoryId,
                            onSelectCategory: (id) async {
                              if (id == 'e_waste') {
                                CustomToast.showDisabledAlert(
                                  context,
                                  message:
                                      'E-Waste collection is currently disabled.',
                                );
                                return;
                              }
                              vm.selectCategory(id);
                              await Navigator.pushNamed(
                                context,
                                '/WasteDetailsScreen',
                                arguments: id,
                              );
                              vm.clearCategorySelection();
                            },
                          ),
                          SizedBox(height: 20.h),

                          // Stats Row (Trees Saved & Reward Points)
                          StatsCards(
                            treesSaved: data.treesSaved,
                            rewardPoints: data.rewardPoints,
                            kgGives: data.monthlyWasteKg,
                          ),
                          SizedBox(height: 16.h),

                          // Waste Activity Card
                          ActivityCard(
                            monthlyKg: data.monthlyWasteKg,
                          ),
                          SizedBox(height: 24.h),

                          // "Book Now" Gradient Action Button
                          InkWell(
                            onTap: () {
                              vm.onBookNowPressed();
                              Navigator.pushNamed(
                                  context, '/WasteDetailsScreen');
                            },
                            borderRadius: BorderRadius.circular(22.r),
                            child: Container(
                              width: 220.w,
                              height: 52.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF2EB872),
                                    Color(0xFF00B4D8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00C853)
                                        .withValues(alpha: 0.25),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Book Now',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                Expanded(child: currentContent),

                // Bottom Navigation Bar
                CustomBottomNavBar(
                  currentIndex: vm.selectedTabIndex,
                  onTap: (index) => vm.setTabIndex(index),
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
