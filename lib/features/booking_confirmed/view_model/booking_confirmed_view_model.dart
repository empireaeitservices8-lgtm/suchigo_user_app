import 'dart:async';
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
    } else {
      isLoading = true;
      try {
        _booking = await _repository.getBookingDetails();
      } catch (e) {
        // Fallback
        _booking = const BookingConfirmedModel();
      } finally {
        isLoading = false;
      }
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
