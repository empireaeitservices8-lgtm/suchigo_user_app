import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_user_app/features/orders/model/pickup_vehicle_tracking_model.dart';
import 'package:suchigo_user_app/features/orders/repo/order_repo.dart';
import '../track_pickup_screen.dart';

class PickupTrackingBottomSheet extends StatefulWidget {
  final int pickupId;

  const PickupTrackingBottomSheet({
    super.key,
    required this.pickupId,
  });

  static Future<void> show(BuildContext context, {required int pickupId}) {
    return Navigator.pushNamed(
      context,
      TrackPickupScreen.routeName,
      arguments: pickupId,
    );
  }

  @override
  State<PickupTrackingBottomSheet> createState() =>
      _PickupTrackingBottomSheetState();
}

class _PickupTrackingBottomSheetState extends State<PickupTrackingBottomSheet> {
  final OrderRepository _repo = OrderRepositoryImpl();
  bool _isLoading = true;
  String? _errorMessage;
  PickupVehicleTrackingModel? _trackingData;

  @override
  void initState() {
    super.initState();
    _fetchTrackingData();
  }

  Future<void> _fetchTrackingData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _repo.getPickupVehicleTracking(
        widget.pickupId,
        onError: (err) {
          if (mounted) {
            setState(() {
              _errorMessage = err.message;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _trackingData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load tracking details: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Handle Bar
            SizedBox(height: 12.h),
            Center(
              child: Container(
                width: 44.w,
                height: 4.5.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Header Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_shipping_rounded,
                        color: Color(0xFF166534),
                        size: 22,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup Vehicle Tracking',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Booking ID: #${widget.pickupId}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 14.h),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            // Body Content
            Flexible(
              child: _isLoading
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 60.h),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF166534),
                        ),
                      ),
                    )
                  : _errorMessage != null
                      ? _buildErrorView()
                      : _buildTrackingContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 48,
          ),
          SizedBox(height: 12.h),
          Text(
            _errorMessage ?? 'Unable to fetch tracking info',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 18.h),
          ElevatedButton.icon(
            onPressed: _fetchTrackingData,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF166534),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingContent() {
    final data = _trackingData;
    if (data == null) {
      return const SizedBox.shrink();
    }

    final hasVehicle =
        data.vehicleName != null && data.vehicleName!.trim().isNotEmpty;
    final hasVehicleNumber =
        data.vehicleNumber != null && data.vehicleNumber!.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Vehicle Info Banner Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: hasVehicle
                  ? const Color(0xFFF0FDF4)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: hasVehicle
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: hasVehicle
                        ? const Color(0xFF166534)
                        : const Color(0xFF94A3B8),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Center(
                    child: Icon(
                      hasVehicle
                          ? Icons.local_shipping_rounded
                          : Icons.access_time_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasVehicle
                            ? (data.vehicleName!)
                            : 'Vehicle Assignment Pending',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        hasVehicleNumber
                            ? 'Reg: ${data.vehicleNumber}'
                            : (hasVehicle
                                ? 'Assigned to your route'
                                : 'Driver allocation in progress'),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: hasVehicle
                              ? const Color(0xFF166534)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: hasVehicle
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    data.displayStatus,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: hasVehicle
                          ? const Color(0xFF15803D)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 18.h),

          // 2. Timeline Step Progress
          _buildTimelineProgress(data.currentStep),

          SizedBox(height: 20.h),

          // 3. Pickup Schedule & Details
          Text(
            'Pickup Details',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 10.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Collection Date',
                  value: data.formattedDate,
                ),
                if (data.pickupTimeSlot.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    icon: Icons.schedule_rounded,
                    label: 'Time Slot',
                    value: data.pickupTimeSlot,
                  ),
                ],
                if (data.fullName.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Contact Name',
                    value: data.fullName,
                  ),
                ],
                if (data.contactNumber.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: data.contactNumber,
                  ),
                ],
                if (data.address.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: data.address,
                    isMultiLine: true,
                  ),
                ],
                if (data.landmark != null && data.landmark!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    icon: Icons.flag_outlined,
                    label: 'Landmark',
                    value: data.landmark!,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Done / Refresh Action
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildTimelineProgress(int currentStep) {
    final steps = [
      {'title': 'Booked', 'icon': Icons.check_circle_rounded},
      {'title': 'Vehicle Assigned', 'icon': Icons.assignment_turned_in_rounded},
      {'title': 'On The Way', 'icon': Icons.directions_car_rounded},
      {'title': 'Collected', 'icon': Icons.task_alt_rounded},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final isDone = index <= currentStep;
        final isCurrent = index == currentStep;
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2.5.h,
                      color: index == 0
                          ? Colors.transparent
                          : (index <= currentStep
                              ? const Color(0xFF166534)
                              : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF166534)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDone
                            ? const Color(0xFF166534)
                            : const Color(0xFFCBD5E1),
                        width: isCurrent ? 2 : 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        steps[index]['icon'] as IconData,
                        size: 14.sp,
                        color: isDone ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 2.5.h,
                      color: isLast
                          ? Colors.transparent
                          : (index < currentStep
                              ? const Color(0xFF166534)
                              : const Color(0xFFE2E8F0)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                steps[index]['title'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isDone ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: const Color(0xFF166534),
        ),
        SizedBox(width: 10.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
