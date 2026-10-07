import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../model/notification_model.dart';
import '../view_model/notification_view_model.dart';
import 'widgets/empty_notification_view.dart';
import 'widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/NotificationScreen';

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F8F4),
        body: Consumer<NotificationViewModel>(
          builder: (context, vm, child) {
            final notifications = vm.filteredNotifications;

            return Column(
              children: [
                // Top Forest Green Header with Tabs
                _buildHeader(context, vm),

                // Notification Content / List
                Expanded(
                  child: vm.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF166534),
                          ),
                        )
                      : notifications.isEmpty
                          ? const EmptyNotificationView(
                              title: 'No notifications found',
                              subtitle: 'No upcoming scheduled reminders.',
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: 18.w,
                                vertical: 16.h,
                              ),
                              itemCount: notifications.length,
                              itemBuilder: (context, index) {
                                return NotificationCard(
                                  notification: notifications[index],
                                  onTap: () {
                                    vm.markAsRead(notifications[index].id);
                                  },
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotificationViewModel vm) {
    return Container(
      color: const Color(0xFF166534),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar: Back Button & Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            // 3 Tabs: All, Upcoming, Delivered
            Row(
              children: [
                _buildTabItem(
                  title: 'All',
                  filter: NotificationFilter.all,
                  isSelected: vm.selectedFilter == NotificationFilter.all,
                  onTap: () => vm.setFilter(NotificationFilter.all),
                ),
                _buildTabItem(
                  title: 'Upcoming',
                  filter: NotificationFilter.upcoming,
                  isSelected: vm.selectedFilter == NotificationFilter.upcoming,
                  onTap: () => vm.setFilter(NotificationFilter.upcoming),
                ),
                _buildTabItem(
                  title: 'Delivered',
                  filter: NotificationFilter.delivered,
                  isSelected: vm.selectedFilter == NotificationFilter.delivered,
                  onTap: () => vm.setFilter(NotificationFilter.delivered),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required NotificationFilter filter,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ),
            // White Indicator Line
            Container(
              height: 3.h,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(3.r)),
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
