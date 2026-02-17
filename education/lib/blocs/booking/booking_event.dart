import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/bookings/booking.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class LoadBookings extends BookingEvent {}

class CreateBooking extends BookingEvent {
  final Booking booking;
  const CreateBooking(this.booking);
  @override
  List<Object?> get props => [booking];
}

class CreateRecurringBooking extends BookingEvent {
  final String tutorId;
  final String studentId;
  final DateTime startDate;
  final String startTime;
  final String endTime;
  final RecurrenceType recurrenceType;
  final DateTime recurrenceEndDate;

  const CreateRecurringBooking({
    required this.tutorId,
    required this.studentId,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.recurrenceType,
    required this.recurrenceEndDate,
  });

  @override
  List<Object?> get props => [tutorId, studentId, startDate, startTime, endTime, recurrenceType, recurrenceEndDate];
}

class UpdateBookingStatus extends BookingEvent {
  final String bookingId;
  final BookingStatus status;
  final String? cancellationReason;

  const UpdateBookingStatus({required this.bookingId, required this.status, this.cancellationReason});

  @override
  List<Object?> get props => [bookingId, status, cancellationReason];
}

class RescheduleBooking extends BookingEvent {
  final String bookingId;
  final DateTime newDate;
  final String newStartTime;
  final String newEndTime;

  const RescheduleBooking({
    required this.bookingId,
    required this.newDate,
    required this.newStartTime,
    required this.newEndTime,
  });

  @override
  List<Object?> get props => [bookingId, newDate, newStartTime, newEndTime];
}

class CancelRecurringGroup extends BookingEvent {
  final String recurrenceGroupId;
  final String? cancellationReason;

  const CancelRecurringGroup({required this.recurrenceGroupId, this.cancellationReason});

  @override
  List<Object?> get props => [recurrenceGroupId, cancellationReason];
}
