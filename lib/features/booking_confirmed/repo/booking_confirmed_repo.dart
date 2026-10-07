import '../model/booking_confirmed_model.dart';

abstract class BookingConfirmedRepository {
  Future<BookingConfirmedModel> getBookingDetails({String? bookingId});
}

class BookingConfirmedRepositoryImpl implements BookingConfirmedRepository {
  @override
  Future<BookingConfirmedModel> getBookingDetails({String? bookingId}) async {
    // Simulated network delay
    await Future.delayed(const Duration(milliseconds: 200));
    return BookingConfirmedModel(
      bookingId: bookingId ?? 'WC-115',
    );
  }
}
