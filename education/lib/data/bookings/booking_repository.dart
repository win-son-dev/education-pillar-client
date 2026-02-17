import 'package:education/data/bookings/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookingsForStudent(String studentId);
  Future<List<Booking>> getBookingsForTutor(String tutorId);
  Future<Booking> createBooking(Booking booking);
  Future<List<Booking>> createRecurringBookings({
    required String tutorId,
    required String studentId,
    required DateTime startDate,
    required String startTime,
    required String endTime,
    required RecurrenceType recurrenceType,
    required DateTime recurrenceEndDate,
  });
  Future<Booking> updateBookingStatus(String bookingId, BookingStatus status, {String? cancellationReason});
  Future<Booking> rescheduleBooking(String bookingId, {required DateTime newDate, required String newStartTime, required String newEndTime});
  Future<void> cancelRecurringGroup(String recurrenceGroupId, {String? cancellationReason});
}
