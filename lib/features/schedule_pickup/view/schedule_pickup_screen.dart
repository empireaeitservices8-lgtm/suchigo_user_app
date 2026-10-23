import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:suchigo_user_app/widgets/custom_toast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:suchigo_user_app/features/booking_confirmed/model/booking_confirmed_model.dart';
import 'package:suchigo_user_app/features/booking_confirmed/view/booking_confirmed_screen.dart';
import 'package:suchigo_user_app/features/map_location/model/map_location_model.dart';
import '../model/schedule_pickup_model.dart';
import '../repo/schedule_pickup_repo.dart';
import '../view_model/schedule_pickup_view_model.dart';
import 'widgets/additional_details_card.dart';
import 'widgets/contact_info_card.dart';
import 'widgets/jurisdiction_card.dart';
import 'widgets/jurisdiction_selection_sheet.dart';
import 'widgets/pickup_location_card.dart';
import 'widgets/pickup_schedule_card.dart';
import 'package:suchigo_user_app/widgets/app_button_widget.dart';

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

  bool _isFetchingSheetData = false;

  void _showLoadingToast(String message, {bool isError = false}) {
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
            color: isError ? const Color(0xFFB91C1C) : const Color(0xFF1E293B),
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
              if (isError)
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                )
              else
                SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Color(0xFF60A5FA),
                  ),
                ),
              SizedBox(width: 14.w),
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _fetchAndOpenSheet({
    required String title,
    required String searchHint,
    required Future<List<JurisdictionOption>> Function() loadItems,
    required String selectedItem,
    int? selectedId,
    bool isWard = false,
    required ValueChanged<JurisdictionOption> onSelect,
    String? loadingMessage,
  }) async {
    if (_isFetchingSheetData) return;
    _isFetchingSheetData = true;

    _showLoadingToast(loadingMessage ?? 'Loading options. Please wait...');

    try {
      final items = await loadItems();
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return JurisdictionSelectionSheet(
            title: title,
            searchHint: searchHint,
            initialItems: items,
            loadItems: loadItems,
            selectedItem: selectedItem,
            selectedId: selectedId,
            isWard: isWard,
            onSelect: onSelect,
          );
        },
      );
    } catch (e) {
      if (mounted) {
        _showLoadingToast('Failed to load $title. Please try again.',
            isError: true);
      }
    } finally {
      _isFetchingSheetData = false;
    }
  }

  void _pickDate(BuildContext context) async {
    if (_viewModel.jurisdiction.localBodyId == null) {
      _showLoadingToast('Please select a local body first', isError: true);
      return;
    }
    if (_viewModel.isLoadingCalendarDates) {
      _showLoadingToast('Loading available pickup dates. Please wait...');
      return;
    }
    final availableDates = _viewModel.upcomingPickupDates;
    if (availableDates.isEmpty) {
      _showLoadingToast(
        'No pickup dates available for ${_viewModel.jurisdiction.localBody}',
        isError: true,
      );
      return;
    }

    final current = _viewModel.pickupDate;
    final initial = current != null && availableDates.contains(current)
        ? current
        : availableDates.first;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: availableDates.first,
      lastDate: availableDates.last,
      selectableDayPredicate: (DateTime val) {
        // Only dates returned by the calendar-dates API are selectable
        return _viewModel.isPickupDateAvailable(val);
      },
      helpText: 'Select Pickup Date',
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
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Top Curved Gradient Header enclosing Action Bar & JurisdictionCard
                  _buildTopCurvedHeader(context: context, vm: vm),

                  // Remaining Form Fields
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    child: Column(
                      children: [
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
                          stateController: vm.stateController,
                          zipCodeController: vm.zipCodeController,
                          onSelectOnMap: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/MapScreen',
                            );
                            if (result != null &&
                                result is SelectedAddressModel) {
                              vm.pickupAddressController.text =
                                  result.fullAddress;
                              if (result.state.isNotEmpty) {
                                vm.stateController.text = result.state;
                              }
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
                        AppButton.gradient(
                          text: 'SUBMIT',
                          height: 54.h,
                          borderRadius: 28.r,
                          isLoading: vm.isLoading,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF26A69A),
                              Color(0xFF00C853),
                              Color(0xFF00B0FF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00C853)
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          textStyle: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                          onTap: () async {
                            final success = await vm.submit(
                              onError: (error) {
                                CustomToast.show(
                                  context,
                                  message: error,
                                );
                              },
                            );
                            if (success && context.mounted) {
                              final pickup = vm.createdPickup;
                              final booking = BookingConfirmedModel(
                                bookingId: pickup != null
                                    ? 'WC-${pickup.id}'
                                    : 'WC-115',
                                status: pickup?.status.isNotEmpty == true
                                    ? (pickup!.status[0].toUpperCase() +
                                        pickup.status.substring(1))
                                    : 'Confirmed',
                                wasteType:
                                    pickup?.wasteTypeName.isNotEmpty == true
                                        ? pickup!.wasteTypeName
                                        : (vm.bagsCountController.text
                                                .trim()
                                                .isNotEmpty
                                            ? vm.bagsCountController.text.trim()
                                            : '1'),
                                collectionDate: vm.pickupDate != null
                                    ? DateFormat('EEEE, d MMM yyyy')
                                        .format(vm.pickupDate!)
                                    : (pickup?.pickupDate.isNotEmpty == true
                                        ? pickup!.pickupDate
                                        : 'Friday, 2 Oct 2026'),
                                estWeight:
                                    '${(int.tryParse(vm.bagsCountController.text) ?? 1) * 2.5} kg',
                                contactName: pickup?.fullName.isNotEmpty == true
                                    ? pickup!.fullName
                                    : (vm.fullNameController.text
                                            .trim()
                                            .isNotEmpty
                                        ? vm.fullNameController.text.trim()
                                        : ''),
                                contactPhone:
                                    pickup?.contactNumber.isNotEmpty == true
                                        ? pickup!.contactNumber
                                        : (vm.contactNumberController.text
                                                .trim()
                                                .isNotEmpty
                                            ? vm.contactNumberController.text
                                                .trim()
                                            : ''),
                                pickupAddress: pickup != null
                                    ? '${pickup.street},\n${pickup.district} – ${pickup.zipCode}'
                                    : (vm.pickupAddressController.text
                                            .trim()
                                            .isNotEmpty
                                        ? '${vm.pickupAddressController.text.trim()}, ${vm.jurisdiction.district != "Not Selected" ? vm.jurisdiction.district : ""} - ${vm.zipCodeController.text.trim().isNotEmpty ? vm.zipCodeController.text.trim() : ""}'
                                        : ''),
                                co2Saved: '2.4 kg',
                                recycledPercent: '85%',
                                treesEquiv: '0.3',
                                standardRate: vm.jurisdiction.ratePerKg != null
                                    ? '₹${vm.jurisdiction.ratePerKg!.toStringAsFixed(2)}/kg'
                                    : '₹40.00/kg',
                              );

                              Navigator.pushReplacementNamed(
                                context,
                                BookingConfirmedScreen.routeName,
                                arguments: booking,
                              );
                            }
                          },
                        ),
                        SizedBox(height: 28.h),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopCurvedHeader({
    required BuildContext context,
    required SchedulePickupViewModel vm,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00C853),
            Color(0xFF00BFA5),
            Color(0xFF00B0FF),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
          child: Column(
            children: [
              // Top Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text(
                    'Schedule Pickup',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
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
              SizedBox(height: 18.h),

              // 1. Jurisdiction & Waste Rate Card nested inside curved gradient
              JurisdictionCard(
                jurisdiction: vm.jurisdiction,
                onSelectDistrict: () {
                  _fetchAndOpenSheet(
                    title: 'Select District',
                    searchHint: 'Search District...',
                    loadingMessage: 'Loading districts. Please wait...',
                    loadItems: () async {
                      final list = await _repository.getDistrictsList(
                        state: vm.jurisdiction.state.isNotEmpty
                            ? vm.jurisdiction.state
                            : 'Kerala',
                      );
                      return list
                          .map((d) => JurisdictionOption(
                                id: d.id,
                                title: d.name,
                                data: d,
                              ))
                          .toList();
                    },
                    selectedItem: vm.jurisdiction.district,
                    selectedId: vm.jurisdiction.districtId,
                    onSelect: (option) {
                      vm.setDistrict(option.title, districtId: option.id);
                    },
                  );
                },
                onSelectLocalBody: () {
                  if (vm.jurisdiction.district == 'Not Selected') {
                    _showLoadingToast('Please select a district first');
                    return;
                  }
                  _fetchAndOpenSheet(
                    title: 'Select Local Body',
                    searchHint: 'Search Local Body...',
                    loadingMessage:
                        'Loading local bodies for ${vm.jurisdiction.district}. Please wait...',
                    loadItems: () async {
                      final list = await _repository.getLocalBodiesList(
                        districtId: vm.jurisdiction.districtId,
                        district: vm.jurisdiction.district,
                      );
                      final rates = await _repository.getDisposalRates();
                      return list.map((lb) {
                        double? rate;
                        try {
                          final match = rates.firstWhere(
                            (r) => r.localBodyId == lb.id,
                          );
                          rate = match.ratePerKg;
                        } catch (_) {}
                        final displayRate = rate != null
                            ? '₹${rate.toStringAsFixed(2)} / kg'
                            : '₹40.00 / kg';
                        return JurisdictionOption(
                          id: lb.id,
                          title: lb.name,
                          subtitle: 'Rate: $displayRate',
                          data: lb,
                        );
                      }).toList();
                    },
                    selectedItem: vm.jurisdiction.localBody,
                    selectedId: vm.jurisdiction.localBodyId,
                    onSelect: (option) {
                      vm.setLocalBody(option.title, localBodyId: option.id);
                    },
                  );
                },
                onSelectWard: () {
                  if (vm.jurisdiction.localBody == 'Not Selected') {
                    _showLoadingToast('Please select a local body first');
                    return;
                  }
                  _fetchAndOpenSheet(
                    title: 'Select Ward Name & Number',
                    searchHint: 'Search Ward Name & Number...',
                    loadingMessage:
                        'Loading wards for ${vm.jurisdiction.localBody}. Please wait...',
                    isWard: true,
                    loadItems: () async {
                      final list = await _repository.getWardsList(
                        localBodyId: vm.jurisdiction.localBodyId,
                        localBody: vm.jurisdiction.localBody,
                      );
                      return list
                          .map((w) => JurisdictionOption(
                                id: w.id,
                                title: w.displayName,
                                subtitle: w.wardNumber > 0
                                    ? 'Ward #${w.wardNumber}'
                                    : null,
                                data: w,
                              ))
                          .toList();
                    },
                    selectedItem: vm.jurisdiction.wardNameAndNumber,
                    selectedId: vm.jurisdiction.wardId,
                    onSelect: (option) {
                      final ward = option.data is WardModel
                          ? option.data as WardModel
                          : null;
                      vm.setWard(
                        option.title,
                        wardId: option.id,
                        wardNumber: ward?.wardNumber,
                      );
                      if (vm.jurisdiction.localBodyId != null) {
                        vm.fetchAndApplyDisposalRate(
                            vm.jurisdiction.localBodyId!);
                      }
                    },
                  );
                },
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
