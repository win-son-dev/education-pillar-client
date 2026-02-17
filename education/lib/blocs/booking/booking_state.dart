import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/bookings/booking.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<Booking> bookings;
  const BookingsLoaded(this.bookings);
  @override
  List<Object?> get props => [bookings];
}

class BookingCreated extends BookingState {
  final Booking booking;
  const BookingCreated(this.booking);
  @override
  List<Object?> get props => [booking];
}

class RecurringBookingsCreated extends BookingState {
  final List<Booking> bookings;
  const RecurringBookingsCreated(this.bookings);
  @override
  List<Object?> get props => [bookings];
}

class BookingStatusUpdated extends BookingState {
  final Booking booking;
  const BookingStatusUpdated(this.booking);
  @override
  List<Object?> get props => [booking];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
  @override
  List<Object?> get props => [message];
}
