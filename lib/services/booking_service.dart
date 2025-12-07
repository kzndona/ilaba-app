import 'package:ilaba/models/booking.dart';

abstract class BookingService {
  Future<Booking> createBooking(Booking booking);
  Future<Booking?> getBooking(String bookingId);
  Future<List<Booking>> getUserBookings(String userId);
  Future<List<Booking>> getBookingsByStatus(String userId, String status);
  Future<void> updateBooking(Booking booking);
  Future<void> cancelBooking(String bookingId);
}

class BookingServiceImpl implements BookingService {
  // TODO: Implement with actual API calls to Supabase
  // Example endpoint: POST /bookings
  // Example endpoint: GET /bookings/:id
  // Example endpoint: GET /users/:userId/bookings
  // Example endpoint: GET /users/:userId/bookings?status=pending
  // Example endpoint: PUT /bookings/:id
  // Example endpoint: DELETE /bookings/:id

  @override
  Future<Booking> createBooking(Booking booking) async {
    throw UnimplementedError('createBooking() not implemented');
  }

  @override
  Future<Booking?> getBooking(String bookingId) async {
    throw UnimplementedError('getBooking() not implemented');
  }

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    throw UnimplementedError('getUserBookings() not implemented');
  }

  @override
  Future<List<Booking>> getBookingsByStatus(String userId, String status) async {
    throw UnimplementedError('getBookingsByStatus() not implemented');
  }

  @override
  Future<void> updateBooking(Booking booking) async {
    throw UnimplementedError('updateBooking() not implemented');
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    throw UnimplementedError('cancelBooking() not implemented');
  }
}
