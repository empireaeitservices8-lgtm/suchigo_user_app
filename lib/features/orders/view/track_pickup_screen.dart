import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/pickup_vehicle_tracking_model.dart';
import '../repo/order_repo.dart';

class TrackPickupScreenArgs {
  final int pickupId;
  final int? orderId;

  const TrackPickupScreenArgs({
    required this.pickupId,
    this.orderId,
  });
}

class TrackPickupScreen extends StatefulWidget {
  static const routeName = '/TrackPickupScreen';

  final int pickupId;
  final int? orderId;

  const TrackPickupScreen({
    super.key,
    required this.pickupId,
    this.orderId,
  });

  @override
  State<TrackPickupScreen> createState() => _TrackPickupScreenState();
}

class _TrackPickupScreenState extends State<TrackPickupScreen> {
  final OrderRepository _repo = OrderRepositoryImpl();
  bool _isLoading = true;
  String? _errorMessage;
  PickupVehicleTrackingModel? _trackingData;

  int get effectivePickupId =>
      (_trackingData?.pickupId != null && _trackingData!.pickupId > 0)
          ? _trackingData!.pickupId
          : widget.pickupId;

  int? get effectiveOrderId =>
      _trackingData?.orderNumber ?? _trackingData?.orderId ?? widget.orderId;

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              effectiveOrderId != null
                  ? 'Track Pickup $effectiveOrderId'
                  : (effectivePickupId > 0
                      ? 'Track Pickup #$effectivePickupId'
                      : 'Track Pickup'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
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
                        if (_trackingData?.hasCollector == true) ...[
                          SizedBox(height: 14.h),
                          // Card 2: Waste Collector Card
                          _buildWasteCollectorCard(),
                        ],
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
    final status = (_trackingData?.status ?? 'pending').toLowerCase().trim();
    final bool isCompleted = status.contains('complete') ||
        status.contains('collected') ||
        status.contains('done');
    final bool isTravelling = !isCompleted && status.contains('travel');
    final bool isInTransit = !isCompleted &&
        (isTravelling ||
            status.contains('transit') ||
            status.contains('on_the_way') ||
            status.contains('on the way') ||
            status.contains('dispatched') ||
            status == 'moving');

    final bool hasVehicle = (_trackingData?.vehicleName != null &&
        _trackingData!.vehicleName!.trim().isNotEmpty);
    final bool hasCollector = _trackingData?.hasCollector == true;
    final bool isAssigned = isCompleted ||
        isInTransit ||
        status.contains('assign') ||
        hasVehicle ||
        hasCollector;

    final String statusBadgeText;
    if (isCompleted) {
      statusBadgeText = 'COLLECTED';
    } else if (isTravelling) {
      statusBadgeText = 'TRAVELLING';
    } else if (isInTransit) {
      statusBadgeText = 'IN TRANSIT';
    } else if (isAssigned) {
      statusBadgeText = 'ASSIGNED';
    } else {
      statusBadgeText = 'IN PROGRESS';
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
          // Header with Title & Live Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collection Status',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          SizedBox(height: 22.h),

          // 3-Step Stepper
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step 1: Assigned
              _buildStepItem(
                isActive: !isAssigned && !isCompleted && !isInTransit,
                isCompleted: isAssigned,
                title: 'Assigned',
                subtitle: isAssigned ? 'Driver allocated' : 'In progress',
                icon: Icons.assignment_turned_in_rounded,
              ),

              // Connector 1
              _buildConnector(isDone: isInTransit || isCompleted),

              // Step 2: Travelling / In Transit
              _buildStepItem(
                isActive: isInTransit,
                isCompleted: isCompleted,
                title: isTravelling ? 'Travelling' : 'In Transit',
                subtitle: isInTransit
                    ? (isTravelling ? 'Vehicle travelling' : 'Truck on the way')
                    : (isCompleted ? 'Completed' : 'Pending dispatch'),
                icon: Icons.local_shipping_rounded,
              ),

              // Connector 2
              _buildConnector(isDone: isCompleted),

              // Step 3: Completed
              _buildStepItem(
                isActive: isCompleted,
                isCompleted: isCompleted,
                title: 'Completed',
                subtitle: 'Waste collected',
                icon: Icons.check_circle_rounded,
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
    required IconData icon,
  }) {
    Color circleBg;
    Color iconColor;
    Widget iconWidget;

    if (isCompleted) {
      circleBg = const Color(0xFF166534);
      iconColor = Colors.white;
      iconWidget = Icon(
        Icons.check_rounded,
        color: iconColor,
        size: 16.sp,
      );
    } else if (isActive) {
      circleBg = const Color(0xFF166534);
      iconColor = Colors.white;
      iconWidget = Icon(
        icon,
        color: iconColor,
        size: 16.sp,
      );
    } else {
      circleBg = const Color(0xFFF1F5F9);
      iconColor = const Color(0xFF94A3B8);
      iconWidget = Container(
        width: 8.w,
        height: 8.w,
        decoration: const BoxDecoration(
          color: Color(0xFF94A3B8),
          shape: BoxShape.circle,
        ),
      );
    }

    return Expanded(
      flex: 3,
      child: Column(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: circleBg,
              shape: BoxShape.circle,
              border: isActive && !isCompleted
                  ? Border.all(color: const Color(0xFF86EFAC), width: 3.5)
                  : null,
              boxShadow: isActive && !isCompleted
                  ? [
                      BoxShadow(
                        color: const Color(0xFF166534).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Center(child: iconWidget),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w700,
              color: (isCompleted || isActive)
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
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color:
                  isActive ? const Color(0xFF15803D) : const Color(0xFF94A3B8),
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
        padding: EdgeInsets.only(top: 15.w),
        child: Container(
          height: 2.5,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF166534) : const Color(0xFFCBD5E1),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }

  Widget _buildWasteCollectorCard() {
    final data = _trackingData;
    final collectorName = (data?.collectorName ?? '').trim();
    if (collectorName.isEmpty) {
      return const SizedBox.shrink();
    }
    final displayName = collectorName;
    final collectorPhone = (data?.collectorPhone ?? '').trim();
    final initialLetter = displayName[0].toUpperCase();

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
                if (collectorPhone.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    collectorPhone,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Green Call Icon Button
          if (collectorPhone.isNotEmpty)
            InkWell(
              onTap: () => _makePhoneCall(collectorPhone),
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
    final status = (data?.status ?? '').toLowerCase().trim();
    final bool isTravelling = status.contains('travel');

    final rawVehicleName = data?.vehicleName?.trim() ?? '';
    final hasVehicle = rawVehicleName.isNotEmpty &&
        rawVehicleName.toLowerCase() != 'null' &&
        rawVehicleName.toLowerCase() != 'none' &&
        rawVehicleName.toLowerCase() != 'pending';
    final vehicleName = hasVehicle
        ? rawVehicleName
        : (isTravelling
            ? 'Vehicle Travelling'
            : 'Vehicle Allocation in Progress');

    final rawVehicleNumber = data?.vehicleNumber?.trim() ?? '';
    final hasVehicleNumber = rawVehicleNumber.isNotEmpty &&
        rawVehicleNumber.toLowerCase() != 'null' &&
        rawVehicleNumber.toLowerCase() != 'none' &&
        rawVehicleNumber.toLowerCase() != 'pending';
    final vehicleNumber = hasVehicleNumber ? rawVehicleNumber : 'Pending';
    final pickupDate = data?.formattedDate.isNotEmpty == true
        ? data!.formattedDate
        : ((data?.pickupDate ?? '').trim().isNotEmpty
            ? data!.pickupDate
            : 'Scheduled');
    final address = (data?.address ?? '').trim().isNotEmpty
        ? data!.address
        : 'Address not available';

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
          // Vehicle Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasVehicle
                          ? 'Vehicle Allocated'
                          : (isTravelling
                              ? 'Vehicle Status'
                              : 'Vehicle Allocation'),
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
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: hasVehicle
                            ? const Color(0xFF1E293B)
                            : (isTravelling
                                ? const Color(0xFF166534)
                                : const Color(0xFFD97706)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              if (hasVehicleNumber)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
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
                )
              else if (isTravelling)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFF86EFAC),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_shipping_rounded,
                        size: 13,
                        color: Color(0xFF166534),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Travelling',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF166534),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Color(0xFFD97706),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'In Progress',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
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
          const Divider(
            height: 1,
            color: Color(0xFFE2E8F0),
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
