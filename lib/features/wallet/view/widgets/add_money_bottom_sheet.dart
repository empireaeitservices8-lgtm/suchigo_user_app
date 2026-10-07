import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../view_model/wallet_view_model.dart';

class AddMoneyBottomSheet extends StatelessWidget {
  const AddMoneyBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WalletViewModel>();

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Title & Close Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Money to Wallet',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(20.r),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFF64748B),
                    size: 22.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Amount Text Field Container
          Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Center(
              child: TextField(
                controller: vm.amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D723B),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 18.h),

          // Quick Amount Chips Row
          Row(
            children: [
              Expanded(
                child: _buildQuickChip(
                  context,
                  amount: 100,
                  onTap: () => vm.setQuickAmount(100),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildQuickChip(
                  context,
                  amount: 200,
                  onTap: () => vm.setQuickAmount(200),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildQuickChip(
                  context,
                  amount: 500,
                  onTap: () => vm.setQuickAmount(500),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Proceed to Pay Button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () async {
                      final success = await vm.proceedToAddMoney();
                      if (success && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Money added successfully to wallet!'),
                            backgroundColor: Color(0xFF1D723B),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D723B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: vm.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'PROCEED TO PAY',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(
    BuildContext context, {
    required double amount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: const Color(0xFF1D723B),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            '+ ₹${amount.toInt()}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1D723B),
            ),
          ),
        ),
      ),
    );
  }
}
