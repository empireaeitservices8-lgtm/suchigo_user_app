import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_user_app/features/booking_confirmed/model/booking_confirmed_model.dart';
import 'package:suchigo_user_app/features/booking_confirmed/view/booking_confirmed_screen.dart';
import 'package:suchigo_user_app/features/map_location/model/map_location_model.dart';
import '../repo/schedule_pickup_repo.dart';
import '../view_model/schedule_pickup_view_model.dart';
import 'widgets/additional_details_card.dart';
import 'widgets/contact_info_card.dart';
import 'widgets/jurisdiction_card.dart';
import 'widgets/jurisdiction_selection_sheet.dart';
import 'widgets/pickup_location_card.dart';
import 'widgets/pickup_schedule_card.dart';

class SchedulePickupScreen extends StatefulWidget {
  static const routeName = '/SchedulePickupScreen';

  const SchedulePickupScreen({super.key});

  @override
  State<SchedulePickupScreen> createState() => _SchedulePickupScreenState();
}

class _SchedulePickupScreenState extends State<SchedulePickupScreen> {
  late SchedulePickupViewModel _viewModel;
  final SchedulePickupRepository _repository = SchedulePickupRepositoryImpl();

  @override
  void initState() {
    super.initState();
    _viewModel = SchedulePickupViewModel(repository: _repository);
  }

  void _showLoadingToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.only(
          bottom: 20.h,
          left: 16.w,
          right: 16.w,
        ),
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E40AF),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.info_rounded,
                    color: Color(0xFF60A5FA),
                    size: 18,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openSelectionSheet({
    required String title,
    required String searchHint,
    required Future<List<String>> Function() loadItems,
    required String selectedItem,
    bool isWard = false,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return JurisdictionSelectionSheet(
          title: title,
          searchHint: searchHint,
          loadItems: loadItems,
          selectedItem: selectedItem,
          isWard: isWard,
          onSelect: onSelect,
        );
      },
    );
  }

  void _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF166534),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _viewModel.setPickupDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F8F4),
        body: Consumer<SchedulePickupViewModel>(
          builder: (context, vm, child) {
            return Column(
              children: [
                // Top Gradient Header Bar
                _buildHeader(context),

                // Main Scrollable Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      children: [
                        // 1. Jurisdiction & Waste Rate Card
                        JurisdictionCard(
                          jurisdiction: vm.jurisdiction,
                          onSelectState: () {
                            _openSelectionSheet(
                              title: 'Select State',
                              searchHint: 'Search State...',
                              loadItems: () => _repository.getStates(),
                              selectedItem: vm.jurisdiction.state,
                              onSelect: (val) => vm.setState(val),
                            );
                          },
                          onSelectDistrict: () {
                            _openSelectionSheet(
                              title: 'Select District',
                              searchHint: 'Search District...',
                              loadItems: () =>
                                  _repository.getDistricts(vm.jurisdiction.state),
                              selectedItem: vm.jurisdiction.district,
                              onSelect: (val) {
                                vm.setDistrict(val);
                                _showLoadingToast(
                                    'Loading local bodies. Please wait...');
                              },
                            );
                          },
                          onSelectLocalBody: () {
                            _openSelectionSheet(
                              title: 'Select Local Body',
                              searchHint: 'Search Local Body...',
                              loadItems: () => _repository
                                  .getLocalBodies(vm.jurisdiction.district),
                              selectedItem: vm.jurisdiction.localBody,
                              onSelect: (val) => vm.setLocalBody(val),
                            );
                          },
                          onSelectWard: () {
                            _openSelectionSheet(
                              title: 'Select Ward Name & Number',
                              searchHint: 'Search Ward Name & Number...',
                              isWard: true,
                              loadItems: () =>
                                  _repository.getWards(vm.jurisdiction.localBody),
                              selectedItem: vm.jurisdiction.wardNameAndNumber,
                              onSelect: (val) {
                                vm.setWard(val);
                                vm.setRatePerKg(5.0);
                              },
                            );
                          },
                        ),
                        SizedBox(height: 18.h),

                        // 2. Contact Information Card
                        ContactInfoCard(
                          fullNameController: vm.fullNameController,
                          contactNumberController: vm.contactNumberController,
                          emailController: vm.emailController,
                        ),
                        SizedBox(height: 18.h),

                        // 3. Pickup Location Card
                        PickupLocationCard(
                          addressController: vm.pickupAddressController,
                          zipCodeController: vm.zipCodeController,
                          onSelectOnMap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/MapScreen',
                            );
                            if (result != null && result is SelectedAddressModel) {
                              vm.pickupAddressController.text =
                                  result.fullAddress;
                              vm.zipCodeController.text = result.zipCode;
                            }
                          },
                        ),
                        SizedBox(height: 18.h),

                        // 4. Pickup Schedule Card
                        PickupScheduleCard(
                          pickupDate: vm.pickupDate,
                          bagsCountController: vm.bagsCountController,
                          onSelectDate: () => _pickDate(context),
                        ),
                        SizedBox(height: 18.h),

                        // 5. Additional Details Card
                        AdditionalDetailsCard(
                          secondaryNumberController:
                              vm.secondaryNumberController,
                          landmarkController: vm.landmarkController,
                        ),
                        SizedBox(height: 24.h),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 54.h,
                          child: InkWell(
                            onTap: vm.isLoading
                                ? null
                                : () async {
                                    final success = await vm.submit();
                                    if (success && context.mounted) {
                                      final booking = BookingConfirmedModel(
                                        bookingId: 'WC-115',
                                        status: 'Confirmed',
                                        wasteType: vm.bagsCountController.text
                                                .trim()
                                                .isNotEmpty
                                            ? vm.bagsCountController.text.trim()
                                            : '1',
                                        collectionDate: vm.pickupDate != null
                                            ? DateFormat('EEEE, d MMM yyyy')
                                                .format(vm.pickupDate!)
                                            : 'Friday, 2 Oct 2026',
                                        estWeight: '2.5 kg',
                                        contactName: vm
                                                .fullNameController.text
                                                .trim()
                                                .isNotEmpty
                                            ? vm.fullNameController.text.trim()
                                            : 'aslam',
                                        contactPhone: vm
                                                .contactNumberController.text
                                                .trim()
                                                .isNotEmpty
                                            ? '+91${vm.contactNumberController.text.trim()}'
                                            : '+917592964952',
                                        pickupAddress: vm
                                                .pickupAddressController.text
                                                .trim()
                                                .isNotEmpty
                                            ? '${vm.pickupAddressController.text.trim()}, ${vm.jurisdiction.district != "Not Selected" ? vm.jurisdiction.district : "Ernakulam"} - ${vm.zipCodeController.text.trim().isNotEmpty ? vm.zipCodeController.text.trim() : "682303"}'
                                            : '9F, Kakkanad, Keralam, 682303,\nIndia,\nErnakulam – 682303',
                                        co2Saved: '2.4 kg',
                                        recycledPercent: '85%',
                                        treesEquiv: '0.3',
                                        standardRate: '₹10/kg',
                                      );

                                      Navigator.pushReplacementNamed(
                                        context,
                                        BookingConfirmedScreen.routeName,
                                        arguments: booking,
                                      );
                                    }
                                  },
                            borderRadius: BorderRadius.circular(28.r),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF26A69A),
                                    Color(0xFF00C853),
                                    Color(0xFF00B0FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00C853)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
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
                                        'SUBMIT',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 28.h),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Back Circle Button
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

            // Title
            Text(
              'Schedule Pickup',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),

            // Right Home Circle Button
            InkWell(
              onTap: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
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
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
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
