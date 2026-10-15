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
                          child: vm.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF166534),
                                  ),
                                )
                              : RefreshIndicator(
                                  color: const Color(0xFF166534),
                                  onRefresh: () => vm.loadBills(),
                                  child: vm.filteredBills.isEmpty
                                      ? SingleChildScrollView(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          child: SizedBox(
                                            height: 320.h,
                                            child: _buildEmptyState(),
                                          ),
                                        )
                                      : ListView.separated(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
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
    final isPaid = bill.status == BillStatus.paid;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.receipt_rounded,
                        color: isPaid
                            ? const Color(0xFF166534)
                            : const Color(0xFFD97706),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.invoiceNumber,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (bill.description.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              bill.description,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '₹${bill.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: isPaid
                      ? const Color(0xFF166534)
                      : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          if (bill.weight > 0 ||
              bill.rate > 0 ||
              bill.paymentMethod.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                if (bill.weight > 0)
                  _buildMetaTag(
                    icon: Icons.scale_rounded,
                    label: '${bill.weight} kg',
                  ),
                if (bill.rate > 0)
                  _buildMetaTag(
                    icon: Icons.currency_rupee_rounded,
                    label: '₹${bill.rate}/kg',
                  ),
                if (bill.paymentMethod.isNotEmpty)
                  _buildMetaTag(
                    icon: Icons.payment_rounded,
                    label: bill.paymentMethod.toUpperCase(),
                  ),
              ],
            ),
          ],
          if (bill.remarks.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              'Remarks: ${bill.remarks}',
              style: TextStyle(
                fontSize: 11.5.sp,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bill.dateString,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isPaid ? 'PAID' : 'PENDING',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: isPaid
                        ? const Color(0xFF166534)
                        : const Color(0xFFDC2626),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: const Color(0xFF64748B),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
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
