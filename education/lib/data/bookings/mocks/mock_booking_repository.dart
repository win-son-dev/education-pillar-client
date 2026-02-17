import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/bookings/booking.dart';
import 'package:education/data/bookings/booking_repository.dart';

class MockBookingRepository implements BookingRepository {
  final List<Booking> _bookings = [
    Booking(
      bookingId: 'booking-1',
      tutorId: 'tutor-1',
      studentId: 'student-1',
      date: DateTime.now().add(const Duration(days: 1)),
      startTime: '9 AM',
      endTime: '10 AM',
      status: BookingStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Booking(
      bookingId: 'booking-2',
      tutorId: 'tutor-2',
      studentId: 'student-1',
      date: DateTime.now().add(const Duration(days: 3)),
      startTime: '3 PM',
      endTime: '4 PM',
      status: BookingStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Booking(
      bookingId: 'booking-3',
      tutorId: 'tutor-1',
      studentId: 'student-1',
      date: DateTime.now().subtract(const Duration(days: 5)),
      startTime: '12 PM',
      endTime: '1 PM',
      status: BookingStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Booking(
      bookingId: 'booking-4',
      tutorId: 'tutor-3',
      studentId: 'student-2',
      date: DateTime.now().add(const Duration(days: 2)),
      startTime: '6 PM',
      endTime: '7 PM',
      status: BookingStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  Future<List<Booking>> getBookingsForStudent(String studentId) async {
    return _bookings.where((b) => b.studentId == studentId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<List<Booking>> getBookingsForTutor(String tutorId) async {
    return _bookings.where((b) => b.tutorId == tutorId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Future<Booking> createBooking(Booking booking) async {
    _bookings.add(booking);
    return booking;
  }

  @override
  Future<List<Booking>> createRecurringBookings({
    required String tutorId,
    required String studentId,
    required DateTime startDate,
    required String startTime,
    required String endTime,
    required RecurrenceType recurrenceType,
    required DateTime recurrenceEndDate,
  }) async {
    final groupId = const Uuid().v4();
    final interval = recurrenceType == RecurrenceType.weekly ? 7 : 14;
    final bookings = <Booking>[];

    var current = startDate;
    while (!current.isAfter(recurrenceEndDate)) {
      final booking = Booking(
        bookingId: const Uuid().v4(),
        tutorId: tutorId,
        studentId: studentId,
        date: current,
        startTime: startTime,
        endTime: endTime,
        status: BookingStatus.pending,
        recurrenceGroupId: groupId,
        recurrenceType: recurrenceType,
        recurrenceEndDate: recurrenceEndDate,
        createdAt: DateTime.now(),
      );
      bookings.add(booking);
      _bookings.add(booking);
      current = current.add(Duration(days: interval));
    }
    return bookings;
  }

  @override
  Future<Booking> updateBookingStatus(String bookingId, BookingStatus status, {String? cancellationReason}) async {
    final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (index == -1) throw Exception('Booking not found');
    _bookings[index] = _bookings[index].copyWith(
      status: status,
      cancellationReason: cancellationReason,
    );
    return _bookings[index];
  }

  @override
  Future<Booking> rescheduleBooking(String bookingId, {required DateTime newDate, required String newStartTime, required String newEndTime}) async {
    final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (index == -1) throw Exception('Booking not found');
    _bookings[index] = _bookings[index].copyWith(
      date: newDate,
      startTime: newStartTime,
      endTime: newEndTime,
    );
    return _bookings[index];
  }

  @override
  Future<void> cancelRecurringGroup(String recurrenceGroupId, {String? cancellationReason}) async {
    for (var i = 0; i < _bookings.length; i++) {
      if (_bookings[i].recurrenceGroupId == recurrenceGroupId &&
          _bookings[i].status != BookingStatus.completed) {
        _bookings[i] = _bookings[i].copyWith(
          status: BookingStatus.cancelled,
          cancellationReason: cancellationReason,
        );
      }
    }
  }
}
