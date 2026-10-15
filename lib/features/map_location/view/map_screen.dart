import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../view_model/map_location_view_model.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/MapScreen';

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapLocationViewModel _viewModel;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _viewModel = MapLocationViewModel();
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF1E6F3E);

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Consumer<MapLocationViewModel>(
          builder: (context, vm, child) {
            return Stack(
              children: [
                // 1. Native Smooth Interactive Google Map
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(vm.currentLat, vm.currentLng),
                      zoom: vm.zoom.toDouble(),
                    ),
                    onMapCreated: vm.onMapCreated,
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    onTap: (latLng) {
                      vm.animateTo(latLng.latitude, latLng.longitude);
                    },
                    onCameraMove: (position) {
                      if (!_isDragging) {
                        setState(() {
                          _isDragging = true;
                        });
                      }
                      vm.onCameraMove(position);
                    },
                    onCameraIdle: () {
                      if (_isDragging) {
                        setState(() {
                          _isDragging = false;
                        });
                      }
                      vm.onCameraIdle();
                    },
                    myLocationEnabled: vm.hasLocationPermission,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                  ),
                ),

                // 2. Center Pin Marker & Tooltip (Transparent to touch gestures)
                Center(
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      transform: Matrix4.translationValues(
                          0, _isDragging ? -14.h : 0, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF263238),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              'Move map to place pin',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFFEF4444),
                            size: 46,
                          ),
                          if (_isDragging)
                            Container(
                              width: 8.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          SizedBox(height: 38.h),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Top Solid Green Header Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(8.w, 4.h, 16.w, 8.h),
                    color: brandGreen,
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Select Location on Map',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. Floating Search Bar (Positioned directly below header with crisp white background)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 56.h + 10.h,
                  left: 16.w,
                  right: 16.w,
                  child: Column(
                    children: [
                      Container(
                        height: 50.h,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: brandGreen,
                              size: 22,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: TextField(
                                controller: vm.searchController,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Search city, area or landmark...',
                                  hintStyle: TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (vm.searchController.text.isNotEmpty)
                              InkWell(
                                onTap: () => vm.searchController.clear(),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Color(0xFF94A3B8),
                                  size: 20,
                                ),
                              )
                            else
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: brandGreen,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                      if (vm.searchResults.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 8.h),
                          constraints: BoxConstraints(maxHeight: 250.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: vm.searchResults.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = vm.searchResults[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.location_on_outlined,
                                  color: brandGreen,
                                ),
                                title: Text(
                                  item.area,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                subtitle: Text(
                                  item.fullAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                onTap: () => vm.selectSearchResult(item),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),

                // 5. Floating GPS My-Location Button
                Positioned(
                  bottom: 225.h,
                  right: 18.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => vm.moveToCurrentLocation(),
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: vm.isLocating
                              ? SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      brandGreen,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.gps_fixed_rounded,
                                  color: brandGreen,
                                  size: 24,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 6. Bottom Address Details & Confirmation Card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Drag Handle Bar
                          Center(
                            child: Container(
                              width: 44.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBD5E1),
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 14.h),

                          // Header Row: Icon + "SELECT PICKUP ADDRESS"
                          Row(
                            children: [
                              Container(
                                width: 22.w,
                                height: 22.w,
                                decoration: const BoxDecoration(
                                  color: brandGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'SELECT PICKUP ADDRESS',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: brandGreen,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),

                          // Full Address Text
                          Text(
                            vm.selectedAddress?.fullAddress ??
                                'Fetching address...',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                              height: 1.35,
                            ),
                          ),
                          SizedBox(height: 4.h),

                          // Coordinates: Lat / Lng
                          Text(
                            'Lat: ${vm.currentLat.toStringAsFixed(5)}, Lng: ${vm.currentLng.toStringAsFixed(5)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 18.h),

                          // Confirm Button
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              onPressed: vm.selectedAddress != null
                                  ? () {
                                      Navigator.pop(
                                        context,
                                        vm.selectedAddress,
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandGreen,
                                disabledBackgroundColor:
                                    brandGreen.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'CONFIRM THIS LOCATION',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
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
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}





