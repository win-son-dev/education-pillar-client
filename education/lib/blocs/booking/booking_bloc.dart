import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/bookings/booking_repository.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/blocs/booking/booking_event.dart';
import 'package:education/blocs/booking/booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;
  final CurrentUserService _currentUserService;

  BookingBloc({
    required BookingRepository bookingRepository,
    required CurrentUserService currentUserService,
  })  : _bookingRepository = bookingRepository,
        _currentUserService = currentUserService,
        super(BookingInitial()) {
    on<LoadBookings>(_onLoadBookings);
    on<CreateBooking>(_onCreateBooking);
    on<CreateRecurringBooking>(_onCreateRecurringBooking);
    on<UpdateBookingStatus>(_onUpdateBookingStatus);
    on<RescheduleBooking>(_onRescheduleBooking);
    on<CancelRecurringGroup>(_onCancelRecurringGroup);
  }

  Future<void> _onLoadBookings(LoadBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final bookings = _currentUserService.isStudent
          ? await _bookingRepository.getBookingsForStudent(_currentUserService.userId)
          : await _bookingRepository.getBookingsForTutor(_currentUserService.userId);
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCreateBooking(CreateBooking event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final booking = await _bookingRepository.createBooking(event.booking);
      emit(BookingCreated(booking));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCreateRecurringBooking(CreateRecurringBooking event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final bookings = await _bookingRepository.createRecurringBookings(
        tutorId: event.tutorId,
        studentId: event.studentId,
        startDate: event.startDate,
        startTime: event.startTime,
        endTime: event.endTime,
        recurrenceType: event.recurrenceType,
        recurrenceEndDate: event.recurrenceEndDate,
      );
      emit(RecurringBookingsCreated(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onUpdateBookingStatus(UpdateBookingStatus event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.updateBookingStatus(
        event.bookingId,
        event.status,
        cancellationReason: event.cancellationReason,
      );
      final bookings = _currentUserService.isStudent
          ? await _bookingRepository.getBookingsForStudent(_currentUserService.userId)
          : await _bookingRepository.getBookingsForTutor(_currentUserService.userId);
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onRescheduleBooking(RescheduleBooking event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.rescheduleBooking(
        event.bookingId,
        newDate: event.newDate,
        newStartTime: event.newStartTime,
        newEndTime: event.newEndTime,
      );
      final bookings = _currentUserService.isStudent
          ? await _bookingRepository.getBookingsForStudent(_currentUserService.userId)
          : await _bookingRepository.getBookingsForTutor(_currentUserService.userId);
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  Future<void> _onCancelRecurringGroup(CancelRecurringGroup event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      await _bookingRepository.cancelRecurringGroup(
        event.recurrenceGroupId,
        cancellationReason: event.cancellationReason,
      );
      final bookings = _currentUserService.isStudent
          ? await _bookingRepository.getBookingsForStudent(_currentUserService.userId)
          : await _bookingRepository.getBookingsForTutor(_currentUserService.userId);
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
