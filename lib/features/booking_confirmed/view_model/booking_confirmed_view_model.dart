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

  BookingConfirmedViewModel({BookingConfirmedRepository? repository})
      : _repository = repository ?? BookingConfirmedRepositoryImpl();

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
    _isToastVisible = false;
    notifyListeners();
  }
}
