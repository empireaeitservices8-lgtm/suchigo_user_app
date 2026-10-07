import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../model/booking_confirmed_model.dart';
import '../view_model/booking_confirmed_view_model.dart';
import 'widgets/booking_bottom_nav_bar.dart';
import 'widgets/booking_confirmed_dialog.dart';
import 'widgets/booking_id_card.dart';
import 'widgets/collection_details_card.dart';
import 'widgets/environmental_impact_card.dart';
import 'widgets/pickup_address_card.dart';

class BookingConfirmedScreen extends StatefulWidget {
  static const routeName = '/BookingConfirmedScreen';

  final BookingConfirmedModel? bookingData;

  const BookingConfirmedScreen({
    super.key,
    this.bookingData,
  });

  @override
  State<BookingConfirmedScreen> createState() => _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState extends State<BookingConfirmedScreen> {
  late BookingConfirmedViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BookingConfirmedViewModel();
    _viewModel.init(widget.bookingData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSuccessPopup();
    });
  }

  void _showSuccessPopup() {
    BookingConfirmedDialog.show(
      context,
      standardRate: _viewModel.booking.standardRate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF5F0),
        body: Consumer<BookingConfirmedViewModel>(
          builder: (context, vm, child) {
            return Stack(
              children: [
                // Main Content
                Column(
                  children: [
                    // Top Header
                    _buildHeader(context),

                    // Scrollable Cards List
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            // 1. Booking ID Card
                            BookingIdCard(
                              bookingId: vm.booking.bookingId,
                              status: vm.booking.status,
                            ),
                            SizedBox(height: 14.h),

                            // 2. Collection Details Card
                            CollectionDetailsCard(
                              wasteType: vm.booking.wasteType,
                              collectionDate: vm.booking.collectionDate,
                              estWeight: vm.booking.estWeight,
                            ),
                            SizedBox(height: 14.h),

                            // 3. Pickup Address Card
                            BookingPickupAddressCard(
                              contactName: vm.booking.contactName,
                              phone: vm.booking.contactPhone,
                              address: vm.booking.pickupAddress,
                            ),
                            SizedBox(height: 14.h),

                            // 4. Environmental Impact Card
                            EnvironmentalImpactCard(
                              co2Saved: vm.booking.co2Saved,
                              recycledPercent: vm.booking.recycledPercent,
                              treesEquiv: vm.booking.treesEquiv,
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Floating Toast Banner: "Pickup scheduled successfully!"
                if (vm.isToastVisible)
                  Positioned(
                    bottom: 74.h,
                    left: 16.w,
                    right: 16.w,
                    child: GestureDetector(
                      onTap: vm.hideToast,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Pickup scheduled successfully!',
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: vm.hideToast,
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: Consumer<BookingConfirmedViewModel>(
          builder: (context, vm, child) {
            return BookingBottomNavBar(
              currentIndex: vm.selectedBottomNavIndex,
              onTap: (index) {
                vm.setBottomNavIndex(index);
                if (index == 0) {
                  // Navigate back to Home
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Confirmed',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Your waste collection has been scheduled.',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),

              // Right Check Icon Button (re-triggers dialog)
              InkWell(
                onTap: _showSuccessPopup,
                borderRadius: BorderRadius.circular(24.r),
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
