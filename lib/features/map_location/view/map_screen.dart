import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  void initState() {
    super.initState();
    _viewModel = MapLocationViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Consumer<MapLocationViewModel>(
          builder: (context, vm, child) {
            return Stack(
              children: [
                // Interactive Vector Map Background Simulation
                Positioned.fill(
                  child: CustomPaint(
                    painter: _VectorMapPainter(),
                  ),
                ),

                // Center Pin Icon
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF166534),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          'Set Pickup Location',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF166534),
                        size: 46,
                      ),
                      SizedBox(height: 38.h),
                    ],
                  ),
                ),

                // Top Gradient Header Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF00BFA5),
                          Color(0xFF00C853),
                          Color(0xFF26A69A),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Text(
                            'Select Location on Map',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating Search Box
                Positioned(
                  top: 110.h,
                  left: 18.w,
                  right: 18.w,
                  child: Column(
                    children: [
                      Container(
                        height: 50.h,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF166534),
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
                                  hintText: 'Search for area, landmark or street...',
                                  hintStyle: TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  border: InputBorder.none,
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
                              ),
                          ],
                        ),
                      ),
                      if (vm.searchResults.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: vm.searchResults.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = vm.searchResults[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0xFF166534),
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

                // Floating GPS My-Location Button
                Positioned(
                  bottom: 240.h,
                  right: 18.w,
                  child: FloatingActionButton.small(
                    onPressed: () => vm.fetchAddressForCurrentLocation(),
                    backgroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: Color(0xFF166534),
                      size: 22,
                    ),
                  ),
                ),

                // Bottom Address Confirmation Card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28.r),
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
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F6EF),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: const Icon(
                                  Icons.location_on_rounded,
                                  color: Color(0xFF166534),
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                'Selected Address',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            vm.selectedAddress?.fullAddress ??
                                'Fetching address...',
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF475569),
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Confirm Button
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: InkWell(
                              onTap: vm.selectedAddress != null
                                  ? () {
                                      Navigator.pop(
                                        context,
                                        vm.selectedAddress,
                                      );
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(26.r),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF26A69A),
                                      Color(0xFF00C853),
                                      Color(0xFF00B0FF),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(26.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00C853)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'CONFIRM LOCATION',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
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

class _VectorMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Map land background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFF1F5F9),
    );

    // Parks / Green zones
    final parkPaint = Paint()..color = const Color(0xFFD4EEDB).withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.18, w * 0.35, h * 0.22),
        const Radius.circular(16),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.6, h * 0.55, w * 0.32, h * 0.18),
        const Radius.circular(16),
      ),
      parkPaint,
    );

    // Major Arterial Roads
    final majorRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Road 1 (Diagonal)
    canvas.drawLine(Offset(-20, h * 0.3), Offset(w + 20, h * 0.7), roadBorderPaint);
    canvas.drawLine(Offset(-20, h * 0.3), Offset(w + 20, h * 0.7), majorRoadPaint);

    // Road 2 (Vertical-ish)
    canvas.drawLine(Offset(w * 0.5, -20), Offset(w * 0.45, h + 20), roadBorderPaint);
    canvas.drawLine(Offset(w * 0.5, -20), Offset(w * 0.45, h + 20), majorRoadPaint);

    // Minor streets
    final minorRoad = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, h * 0.45), Offset(w, h * 0.45), minorRoad);
    canvas.drawLine(Offset(0, h * 0.6), Offset(w, h * 0.6), minorRoad);
    canvas.drawLine(Offset(w * 0.25, 0), Offset(w * 0.25, h), minorRoad);
    canvas.drawLine(Offset(w * 0.75, 0), Offset(w * 0.75, h), minorRoad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
