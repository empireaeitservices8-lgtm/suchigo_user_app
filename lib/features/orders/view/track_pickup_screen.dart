import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/pickup_vehicle_tracking_model.dart';
import '../repo/order_repo.dart';

class TrackPickupScreen extends StatefulWidget {
  static const routeName = '/TrackPickupScreen';

  final int pickupId;

  const TrackPickupScreen({
    super.key,
    required this.pickupId,
  });

  @override
  State<TrackPickupScreen> createState() => _TrackPickupScreenState();
}

class _TrackPickupScreenState extends State<TrackPickupScreen> {
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contact: $phoneNumber'),
            backgroundColor: const Color(0xFF1D723B),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D723B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Track Pickup #WC-${widget.pickupId}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: _fetchTrackingData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1D723B),
              ),
            )
          : _errorMessage != null && _trackingData == null
              ? _buildErrorView()
              : RefreshIndicator(
                  color: const Color(0xFF1D723B),
                  onRefresh: _fetchTrackingData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      children: [
                        // Card 1: Collection Status Stepper
                        _buildCollectionStatusCard(),
                        SizedBox(height: 14.h),

                        // Card 2: Waste Collector Card
                        _buildWasteCollectorCard(),
                        SizedBox(height: 14.h),

                        // Card 3: Vehicle & Pickup Details Card
                        _buildVehicleAndDetailsCard(),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildCollectionStatusCard() {
    final status = (_trackingData?.status ?? 'pending').toLowerCase();
    int currentStep = 0;
    if (status.contains('complete') || status.contains('collected')) {
      currentStep = 2;
    } else if (status.contains('transit') ||
        status.contains('on_the_way') ||
        status.contains('dispatched')) {
      currentStep = 1;
    } else {
      currentStep = 0; // Assigned
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Collection Status',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 20.h),

          // 3-Step Stepper
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step 1: Assigned
              _buildStepItem(
                isActive: currentStep >= 0,
                isCompleted: currentStep >= 0,
                title: 'Assigned',
                subtitle: 'Driver allocated',
              ),

              // Connector 1
              _buildConnector(isDone: currentStep >= 1),

              // Step 2: In Transit
              _buildStepItem(
                isActive: currentStep >= 1,
                isCompleted: currentStep >= 1,
                title: 'In Transit',
                subtitle: 'Truck on the way',
              ),

              // Connector 2
              _buildConnector(isDone: currentStep >= 2),

              // Step 3: Completed
              _buildStepItem(
                isActive: currentStep >= 2,
                isCompleted: currentStep >= 2,
                title: 'Completed',
                subtitle: 'Waste collected',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required bool isActive,
    required bool isCompleted,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      flex: 3,
      child: Column(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF166534)
                  : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    )
                  : Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: const BoxDecoration(
                        color: Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
              color: isCompleted
                  ? const Color(0xFF166534)
                  : const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5.sp,
              color: const Color(0xFF94A3B8),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector({required bool isDone}) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.only(top: 12.w),
        child: Container(
          height: 2,
          color: isDone ? const Color(0xFF166534) : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  Widget _buildWasteCollectorCard() {
    final data = _trackingData;
    final fullName = (data?.fullName ?? '').trim();
    final displayName = fullName.isNotEmpty ? fullName : 'raina';
    final contactNumber =
        (data?.contactNumber ?? '').trim().isNotEmpty
            ? data!.contactNumber
            : '+917306929058';
    final initialLetter =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'R';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Avatar with Letter
          Container(
            width: 52.w,
            height: 52.w,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initialLetter,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1D723B),
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),

          // Name and Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waste Collector',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  contactNumber,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Green Call Icon Button
          InkWell(
            onTap: () => _makePhoneCall(contactNumber),
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.phone_rounded,
                  color: Color(0xFF1D723B),
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleAndDetailsCard() {
    final data = _trackingData;
    final vehicleName =
        (data?.vehicleName != null && data!.vehicleName!.trim().isNotEmpty)
            ? data.vehicleName!
            : 'Collection Truck';
    final vehicleNumber = (data?.vehicleNumber != null &&
            data!.vehicleNumber!.trim().isNotEmpty)
        ? data.vehicleNumber!
        : 'KL-01-1234';
    final pickupDate = (data?.pickupDate ?? '').trim().isNotEmpty
        ? data!.pickupDate
        : '2026-10-09';
    final address = (data?.address ?? '').trim().isNotEmpty
        ? data!.address
        : '9F, Infopark Phase 2, Kochi, Kakkanad, Keralam 682303, India, Ernakulam, Ernakulam, Kerala';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Allocated',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    vehicleName,
                    style: TextStyle(
                      fontSize: 15.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),

              // Yellow Number Plate Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: const Color(0xFFF59E0B),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  vehicleNumber,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD97706),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
          ),
          SizedBox(height: 14.h),

          // Pickup Date Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: const Color(0xFF94A3B8),
                size: 18.sp,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pickup Date',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    pickupDate,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Collection Address Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: const Color(0xFF94A3B8),
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Collection Address',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
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
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _fetchTrackingData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D723B),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
