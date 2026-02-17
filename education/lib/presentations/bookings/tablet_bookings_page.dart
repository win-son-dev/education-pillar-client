import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/booking/booking_bloc.dart';
import 'package:education/blocs/booking/booking_event.dart';
import 'package:education/blocs/booking/booking_state.dart';
import 'package:education/data/bookings/booking.dart';
import 'package:education/presentations/bookings/booking_sections.dart';

class TabletBookingsPage extends StatelessWidget {
  const TabletBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingsLoaded) {
            return BookingCalendarView(
              bookings: state.bookings,
              theme: theme,
              onCancel: (b) {
                context.read<BookingBloc>().add(UpdateBookingStatus(
                  bookingId: b.bookingId,
                  status: BookingStatus.cancelled,
                ));
              },
              onReschedule: (b, newDate, newStartTime, newEndTime) {
                context.read<BookingBloc>().add(RescheduleBooking(
                  bookingId: b.bookingId,
                  newDate: newDate,
                  newStartTime: newStartTime,
                  newEndTime: newEndTime,
                ));
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
