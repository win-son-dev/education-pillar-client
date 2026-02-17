import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/booking/booking_bloc.dart';
import 'package:education/blocs/booking/booking_event.dart';
import 'package:education/blocs/booking/booking_state.dart';
import 'package:education/blocs/tutor_profile/tutor_profile_bloc.dart';
import 'package:education/blocs/tutor_profile/tutor_profile_state.dart';
import 'package:education/data/bookings/booking.dart';
import 'package:education/data/schedules/schedule_slot.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/di/service_locator.dart';
import 'package:education/presentations/booking/booking_sections.dart';

class BookingFlowPage extends StatefulWidget {
  const BookingFlowPage({super.key});

  @override
  State<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends State<BookingFlowPage> {
  int _currentStep = 0; // 0=select slot+recurrence, 1=confirm, 2=success
  ScheduleSlot? _selectedSlot;
  RecurrenceType _recurrenceType = RecurrenceType.none;
  DateTime? _recurrenceEndDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCreated || state is RecurringBookingsCreated) {
          setState(() => _currentStep = 2);
        }
        if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_currentStep == 2 ? 'Booked!' : 'Book a Lesson'),
        ),
        body: BlocBuilder<TutorProfileBloc, TutorProfileState>(
          builder: (context, tutorState) {
            if (tutorState is! TutorProfileLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            switch (_currentStep) {
              case 0:
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      RecurrenceStep(
                        recurrenceType: _recurrenceType,
                        recurrenceEndDate: _recurrenceEndDate,
                        onRecurrenceTypeChanged: (type) => setState(() => _recurrenceType = type),
                        onEndDateChanged: (date) => setState(() => _recurrenceEndDate = date),
                        theme: theme,
                      ),
                      SlotSelectionStep(
                        slots: tutorState.slots,
                        selectedSlot: _selectedSlot,
                        onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
                        theme: theme,
                      ),
                      if (_selectedSlot != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => setState(() => _currentStep = 1),
                              child: const Text('Continue'),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              case 1:
                return SingleChildScrollView(
                  child: BookingConfirmationStep(
                    tutorName: tutorState.tutor.name,
                    slot: _selectedSlot!,
                    recurrenceType: _recurrenceType,
                    recurrenceEndDate: _recurrenceEndDate,
                    hourlyRate: tutorState.tutor.hourlyRate,
                    theme: theme,
                    onConfirm: () => _confirmBooking(tutorState),
                  ),
                );
              case 2:
                return BookingSuccessStep(
                  theme: theme,
                  onViewBookings: () => context.go('/schedule'),
                  onDone: () => context.pop(),
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  void _confirmBooking(TutorProfileLoaded tutorState) {
    final currentUser = sl<CurrentUserService>();
    final bloc = context.read<BookingBloc>();

    if (_recurrenceType == RecurrenceType.none) {
      bloc.add(CreateBooking(Booking(
        bookingId: const Uuid().v4(),
        tutorId: tutorState.tutor.userId,
        studentId: currentUser.userId,
        date: _selectedSlot!.date,
        startTime: _selectedSlot!.startTime,
        endTime: _selectedSlot!.endTime,
        createdAt: DateTime.now(),
      )));
    } else {
      bloc.add(CreateRecurringBooking(
        tutorId: tutorState.tutor.userId,
        studentId: currentUser.userId,
        startDate: _selectedSlot!.date,
        startTime: _selectedSlot!.startTime,
        endTime: _selectedSlot!.endTime,
        recurrenceType: _recurrenceType,
        recurrenceEndDate: _recurrenceEndDate ?? DateTime.now().add(const Duration(days: 90)),
      ));
    }
  }
}
