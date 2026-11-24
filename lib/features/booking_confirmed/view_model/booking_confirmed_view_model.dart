import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:suchigo_user_app/providers/view_model.dart';
import '../model/booking_confirmed_model.dart';
import '../repo/booking_confirmed_repo.dart';

class BookingConfirmedViewModel extends ViewModel {
  final BookingConfirmedRepository _repository;

  BookingConfirmedModel _booking = const BookingConfirmedModel();
  BookingConfirmedModel get booking => _booking;

  int _selectedBottomNavIndex = 0;
  int get selectedBottomNavIndex => _selectedBottomNavIndex;

  bool _isToastVisible = true;
  bool get isToastVisible => _isToastVisible;
  Timer? _toastTimer;

  BookingConfirmedViewModel({BookingConfirmedRepository? repository})
      : _repository = repository ?? BookingConfirmedRepositoryImpl() {
    _startToastTimer();
  }

  void _startToastTimer() {
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(seconds: 2), () {
      hideToast();
    });
  }

  Future<void> init(BookingConfirmedModel? initialData) async {
    if (initialData != null) {
      _booking = initialData;
      notifyListeners();

      // If orderId is missing or empty, fetch latest booking details from API to populate orderId!
      if (_booking.orderId == null || _booking.orderId!.isEmpty) {
        try {
          final targetId =
              _booking.pickupId?.toString() ?? _booking.bookingId;
          final refreshed =
              await _repository.getBookingDetails(bookingId: targetId);
          if (refreshed.orderId != null && refreshed.orderId!.isNotEmpty) {
            _booking = _booking.copyWith(
              orderId: refreshed.orderId,
              bookingId: refreshed.bookingId.isNotEmpty
                  ? refreshed.bookingId
                  : _booking.bookingId,
              pickupId: refreshed.pickupId ?? _booking.pickupId,
              status: refreshed.status.isNotEmpty
                  ? refreshed.status
                  : _booking.status,
            );
            notifyListeners();
          }
        } catch (e) {
          debugPrint(
              '[BookingConfirmedViewModel] Error refreshing booking details: $e');
        }
      }
    } else {
      isLoading = true;
      notifyListeners();
      try {
        _booking = await _repository.getBookingDetails();
      } catch (e) {
        debugPrint(
            '[BookingConfirmedViewModel] Error loading booking details: $e');
        _booking = const BookingConfirmedModel();
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchBookingDetails({String? bookingId}) async {
    isLoading = true;
    notifyListeners();
    try {
      _booking = await _repository.getBookingDetails(bookingId: bookingId);
    } catch (e) {
      debugPrint('[BookingConfirmedViewModel] fetchBookingDetails error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setBottomNavIndex(int index) {
    _selectedBottomNavIndex = index;
    notifyListeners();
  }

  void hideToast() {
    _toastTimer?.cancel();
    _toastTimer = null;
    if (_isToastVisible) {
      _isToastVisible = false;
      notifyListeners();
    }
  }

  void showToast() {
    _isToastVisible = true;
    notifyListeners();
    _startToastTimer();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _toastTimer = null;
    super.dispose();
  }
}
