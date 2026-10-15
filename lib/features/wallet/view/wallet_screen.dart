import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:suchigo_user_app/helpers/sp_helper.dart';
import 'package:suchigo_user_app/utils/sp_keys.dart' as sp_keys;
import 'package:suchigo_user_app/widgets/custom_toast.dart';
import '../model/wallet_model.dart';
import '../view_model/wallet_view_model.dart';
import 'widgets/add_money_bottom_sheet.dart';

class WalletScreen extends StatefulWidget {
  static const routeName = '/WalletScreen';

  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late WalletViewModel _viewModel;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _viewModel = WalletViewModel();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _viewModel.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('[WalletScreen] Razorpay SUCCESS: ${response.paymentId}');
    if (mounted) {
      CustomToast.show(
        context,
        message: 'Payment Successful! Payment ID: ${response.paymentId}',
      );
      _viewModel.loadWalletData();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
        '[WalletScreen] Razorpay ERROR: ${response.code} - ${response.message}');
    if (mounted) {
      CustomToast.show(
        context,
        message: response.message ?? 'Payment Cancelled or Failed',
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('[WalletScreen] External Wallet: ${response.walletName}');
    if (mounted) {
      CustomToast.show(
        context,
        message: 'External wallet selected: ${response.walletName}',
      );
    }
  }

  Future<void> _openRazorpay(RazorpayOrderModel order) async {
    final phone =
        await SpHelper.getString(sp_keys.keyUseMobile) ?? '+917306929058';
    final email = await SpHelper.getString(sp_keys.keyEmail) ?? '';

    final options = {
      'key': order.keyId,
      'amount': order.amount,
      'name': 'SuchiGo',
      'order_id': order.orderId,
      'description': 'Wallet Refill',
      'timeout': 300,
      'prefill': {
        'contact': phone,
        'email': email,
      },
    };

    debugPrint('[WalletScreen] Opening Razorpay with options: $options');
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('[WalletScreen] Error opening Razorpay: $e');
      if (mounted) {
        CustomToast.show(
          context,
          message: 'Unable to open payment gateway: $e',
        );
      }
    }
  }

  void _showAddMoneySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: _viewModel,
        child: AddMoneyBottomSheet(
          onOrderCreated: (order) {
            _openRazorpay(order);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFEEFAF0),
        body: Consumer<WalletViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                // Top Deep Green Section (Header + Balance Card + Curved Bottom)
                _buildTopGreenSection(context, vm),

                // Main Scrollable Transaction History
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF166534),
                    onRefresh: () async => vm.loadWalletData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Transaction History Heading
                          Text(
                            'Transaction History',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 14.h),

                          // Transactions List
                          if (vm.transactions.isEmpty)
                            _buildEmptyState()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: vm.transactions.length,
                              separatorBuilder: (ctx, i) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (ctx, index) {
                                return _buildTransactionItem(
                                  vm.transactions[index],
                                );
                              },
                            ),

                          SizedBox(height: 20.h),
                        ],
                      ),
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

  Widget _buildTopGreenSection(BuildContext context, WalletViewModel vm) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF4BB14E),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(36.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4BB14E).withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Title Bar
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8ECC8E).withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'SuchiGo Wallet',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              // Available Balance Card (sitting inside the top green header)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(22.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1D723B),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Available Balance & ACTIVE pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 13.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'ACTIVE',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Large Balance Number
                    Text(
                      '₹ ${vm.availableBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Add Money White Pill Button
                    InkWell(
                      onTap: _showAddMoneySheet,
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        width: double.infinity,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              color: Color(0xFF1D723B),
                              size: 20,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'ADD MONEY',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1D723B),
                                letterSpacing: 0.5,
                              ),
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
      ),
    );
  }

  Widget _buildTransactionItem(WalletTransactionModel item) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Icon
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: item.isWelcomeIncentive
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                item.isWelcomeIncentive
                    ? Icons.eco_rounded
                    : Icons.swap_horiz_rounded,
                color: item.isWelcomeIncentive
                    ? const Color(0xFF166534)
                    : const Color(0xFF64748B),
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(width: 14.w),

          // Title & Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  item.dateString,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            item.formattedAmount,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: item.isWelcomeIncentive
                  ? const Color(0xFF166534)
                  : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Text(
          'No transactions found',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
