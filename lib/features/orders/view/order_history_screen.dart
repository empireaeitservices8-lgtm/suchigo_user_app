import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_user_app/features/home/view/home_screen.dart';
import 'package:suchigo_user_app/features/home/view/widgets/bottom_nav_bar.dart';
import 'package:suchigo_user_app/features/schedule_pickup/view/schedule_pickup_screen.dart';
import 'package:suchigo_user_app/widgets/app_button_widget.dart';
import '../model/order_model.dart';
import '../view_model/order_view_model.dart';
import 'track_pickup_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  static const routeName = '/OrderHistoryScreen';

  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late OrderViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OrderViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFEEFAF0),
        body: Consumer<OrderViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                // Top Green Header with Welcome Banner
                _buildHeader(context, vm),

                // Main Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter Pills (All, Completed, Pending, Cancelled)
                        _buildFilterTabs(vm),

                        SizedBox(height: 16.h),

                        // Orders List / Loader / Empty State
                        Expanded(
                          child: vm.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF166534),
                                  ),
                                )
                              : RefreshIndicator(
                                  color: const Color(0xFF166534),
                                  onRefresh: () => vm.loadOrders(),
                                  child: vm.filteredOrders.isEmpty
                                      ? SingleChildScrollView(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          child: SizedBox(
                                            height: 340.h,
                                            child: _buildEmptyState(),
                                          ),
                                        )
                                      : ListView.separated(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemCount: vm.filteredOrders.length,
                                          separatorBuilder: (ctx, i) =>
                                              SizedBox(height: 16.h),
                                          itemBuilder: (ctx, index) {
                                            return _buildOrderCard(
                                              context,
                                              vm.filteredOrders[index],
                                            );
                                          },
                                        ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 2,
          onTap: (index) {
            if (index == 2) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  HomeScreen.routeName,
                  (route) => false,
                  arguments: 2,
                );
              }
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomeScreen.routeName,
                (route) => false,
                arguments: index,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OrderViewModel vm) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF4BB14E),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4BB14E).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
          child: Column(
            children: [
              // Header Title Bar
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20.r),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8ECC8E).withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Order History',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Welcome Back White Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                  vertical: 16.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Welcome back, ${vm.userName}! 👏',
                      style: TextStyle(
                        fontSize: 17.5.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Manage your waste collection and track your environmental impact',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
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
      ),
    );
  }

  Widget _buildFilterTabs(OrderViewModel vm) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All',
            isSelected: vm.selectedFilter == OrderStatus.all,
            onTap: () => vm.setFilter(OrderStatus.all),
          ),
          SizedBox(width: 10.w),
          _buildFilterChip(
            label: 'Completed',
            isSelected: vm.selectedFilter == OrderStatus.completed,
            onTap: () => vm.setFilter(OrderStatus.completed),
          ),
          SizedBox(width: 10.w),
          _buildFilterChip(
            label: 'Pending',
            isSelected: vm.selectedFilter == OrderStatus.pending,
            onTap: () => vm.setFilter(OrderStatus.pending),
          ),
          SizedBox(width: 10.w),
          _buildFilterChip(
            label: 'Cancelled',
            isSelected: vm.selectedFilter == OrderStatus.cancelled,
            onTap: () => vm.setFilter(OrderStatus.cancelled),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.5.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D723B) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1D723B)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1D723B).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Recycling Icon + Waste Type Name & WC Code + Status Badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.recycling_rounded,
                          color: const Color(0xFF1D723B),
                          size: 24.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            order.code,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),

              // Status Badge
              _buildStatusBadge(order.orderStatus, order.statusLabel),
            ],
          ),

          SizedBox(height: 16.h),

          // Date Row
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            text: order.dateString,
          ),
          SizedBox(height: 8.h),

          // Address Row
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            text: order.address,
          ),
          SizedBox(height: 8.h),

          // Weight Row
          _buildInfoRow(
            icon: Icons.scale_outlined,
            text: '${order.weightKg.toStringAsFixed(1)} kg',
          ),

          SizedBox(height: 14.h),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          SizedBox(height: 14.h),

          // Action Button
          _buildActionButtons(context, order),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderModel order) {
    if (order.orderStatus == OrderStatus.cancelled ||
        order.orderStatus == OrderStatus.completed) {
      return SizedBox(
        width: double.infinity,
        child: AppButton(
          text: 'Repeat Booking',
          height: 44.h,
          borderRadius: 12.r,
          backgroundColor: const Color(0xFF1D723B),
          fontSize: 14.sp,
          prefixIcon: Icon(
            Icons.repeat_rounded,
            color: Colors.white,
            size: 18.sp,
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              SchedulePickupScreen.routeName,
            );
          },
        ),
      );
    }

    // Pending / In-progress: Show both Track Vehicle and Repeat Booking
    return Row(
      children: [
        // Track Vehicle
        Expanded(
          child: AppButton.outlined(
            text: 'Track Vehicle',
            height: 44.h,
            borderRadius: 12.r,
            borderColor: const Color(0xFF1D723B),
            textColor: const Color(0xFF1D723B),
            fontSize: 13.sp,
            prefixIcon: Icon(
              Icons.my_location_rounded,
              color: const Color(0xFF1D723B),
              size: 16.sp,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                TrackPickupScreen.routeName,
                arguments: order.id,
              );
            },
          ),
        ),
        SizedBox(width: 10.w),

        // Repeat Booking
        Expanded(
          child: AppButton(
            text: 'Repeat Booking',
            height: 44.h,
            borderRadius: 12.r,
            backgroundColor: const Color(0xFF1D723B),
            fontSize: 13.sp,
            prefixIcon: Icon(
              Icons.repeat_rounded,
              color: Colors.white,
              size: 16.sp,
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                SchedulePickupScreen.routeName,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF94A3B8),
          size: 16.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5.sp,
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(OrderStatus status, String label) {
    Color bg;
    Color text;
    String iconEmoji;

    switch (status) {
      case OrderStatus.completed:
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF1D723B);
        iconEmoji = '✔';
        break;
      case OrderStatus.pending:
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        iconEmoji = '⏳';
        break;
      case OrderStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        iconEmoji = '✕';
        break;
      case OrderStatus.all:
        bg = const Color(0xFFE2E8F0);
        text = const Color(0xFF475569);
        iconEmoji = '•';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '$iconEmoji  $label',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50.h),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48.sp,
              color: const Color(0xFFCBD5E1),
            ),
            SizedBox(height: 12.h),
            Text(
              'No pickup orders found',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Your scheduled waste collections will appear here',
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
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
