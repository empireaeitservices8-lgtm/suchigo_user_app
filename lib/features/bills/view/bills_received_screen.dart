import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../model/bill_model.dart';
import '../view_model/bill_view_model.dart';

class BillsReceivedScreen extends StatefulWidget {
  static const routeName = '/BillsReceivedScreen';

  const BillsReceivedScreen({super.key});

  @override
  State<BillsReceivedScreen> createState() => _BillsReceivedScreenState();
}

class _BillsReceivedScreenState extends State<BillsReceivedScreen> {
  late BillViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BillViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFEEFAF0),
        body: Consumer<BillViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                // Top Green Header with Summary Card
                _buildHeader(context, vm),

                // Main Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      children: [
                        // Segmented Filter Tabs (All, Pending, Paid)
                        _buildFilterTabs(vm),

                        SizedBox(height: 24.h),

                        // Bills List / Empty State
                        Expanded(
                          child: vm.filteredBills.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  itemCount: vm.filteredBills.length,
                                  separatorBuilder: (ctx, i) =>
                                      SizedBox(height: 12.h),
                                  itemBuilder: (ctx, index) {
                                    return _buildBillItem(
                                      vm.filteredBills[index],
                                    );
                                  },
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BillViewModel vm) {
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
              Row(
                children: [
                  InkWell(
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
                  SizedBox(width: 12.w),
                  Text(
                    'Bills Received',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Summary Card (Pending Bills vs Paid This Month)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 18.h,
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
                child: Row(
                  children: [
                    // Pending Bills (Red)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PENDING BILLS',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '₹${vm.summary.pendingBills.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFE53935),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Container(
                      width: 1.0,
                      height: 40.h,
                      color: const Color(0xFFE2E8F0),
                    ),
                    SizedBox(width: 20.w),

                    // Paid This Month (Green)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PAID THIS MONTH',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '₹${vm.summary.paidThisMonth.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1D723B),
                            ),
                          ),
                        ],
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

  Widget _buildFilterTabs(BillViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              label: 'All',
              isSelected: vm.selectedFilter == BillStatus.all,
              onTap: () => vm.setFilter(BillStatus.all),
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              label: 'Pending',
              isSelected: vm.selectedFilter == BillStatus.pending,
              onTap: () => vm.setFilter(BillStatus.pending),
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              label: 'Paid',
              isSelected: vm.selectedFilter == BillStatus.paid,
              onTap: () => vm.setFilter(BillStatus.paid),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44.h,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D723B) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular Receipt Icon Badge
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.receipt_long_rounded,
                size: 54.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Title
          Text(
            'No Bills Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8.h),

          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Your waste collection invoices will appear here once generated by the collector.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: const Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillItem(BillModel bill) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bill.invoiceNumber,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                bill.dateString,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          Text(
            '₹${bill.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: bill.status == BillStatus.paid
                  ? const Color(0xFF1D723B)
                  : const Color(0xFFE53935),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
