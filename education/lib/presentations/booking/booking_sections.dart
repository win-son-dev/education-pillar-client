import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/bookings/booking.dart';
import 'package:education/data/schedules/schedule_slot.dart';

class SlotSelectionStep extends StatelessWidget {
  final List<ScheduleSlot> slots;
  final ScheduleSlot? selectedSlot;
  final ValueChanged<ScheduleSlot> onSlotSelected;
  final ThemeData theme;

  const SlotSelectionStep({
    super.key,
    required this.slots,
    this.selectedSlot,
    required this.onSlotSelected,
    required this.theme,
  });

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _timeSlots = ['9 AM', '12 PM', '3 PM', '6 PM'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Select a time slot', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  const SizedBox(width: 48),
                  ..._days.map((d) => Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(d, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  )),
                ],
              ),
              for (var i = 0; i < _timeSlots.length; i++)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(_timeSlots[i], style: theme.textTheme.labelSmall),
                    ),
                    for (var j = 0; j < _days.length; j++)
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Builder(builder: (context) {
                          final slot = slots.cast<ScheduleSlot?>().firstWhere(
                            (s) => s!.date.weekday == j + 1 && s.startTime == _timeSlots[i],
                            orElse: () => null,
                          );
                          final isSelected = slot != null && selectedSlot?.slotId == slot.slotId;
                          final isAvailable = slot != null && !slot.isBooked;
                          return GestureDetector(
                            onTap: isAvailable ? () => onSlotSelected(slot) : null,
                            child: Container(
                              height: 28,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : isAvailable
                                        ? theme.colorScheme.primaryContainer
                                        : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class RecurrenceStep extends StatelessWidget {
  final RecurrenceType recurrenceType;
  final DateTime? recurrenceEndDate;
  final ValueChanged<RecurrenceType> onRecurrenceTypeChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final ThemeData theme;

  const RecurrenceStep({
    super.key,
    required this.recurrenceType,
    this.recurrenceEndDate,
    required this.onRecurrenceTypeChanged,
    required this.onEndDateChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recurrence', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SegmentedButton<RecurrenceType>(
            segments: const [
              ButtonSegment(value: RecurrenceType.none, label: Text('One-time')),
              ButtonSegment(value: RecurrenceType.weekly, label: Text('Weekly')),
              ButtonSegment(value: RecurrenceType.biweekly, label: Text('Biweekly')),
            ],
            selected: {recurrenceType},
            onSelectionChanged: (s) => onRecurrenceTypeChanged(s.first),
          ),
          if (recurrenceType != RecurrenceType.none) ...[
            const SizedBox(height: 16),
            Text('End date', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: recurrenceEndDate ?? DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) onEndDateChanged(date);
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(recurrenceEndDate != null
                  ? '${recurrenceEndDate!.day}/${recurrenceEndDate!.month}/${recurrenceEndDate!.year}'
                  : 'Select end date'),
            ),
          ],
        ],
      ),
    );
  }
}

class BookingConfirmationStep extends StatelessWidget {
  final String tutorName;
  final ScheduleSlot slot;
  final RecurrenceType recurrenceType;
  final DateTime? recurrenceEndDate;
  final double hourlyRate;
  final VoidCallback onConfirm;
  final ThemeData theme;

  const BookingConfirmationStep({
    super.key,
    required this.tutorName,
    required this.slot,
    required this.recurrenceType,
    this.recurrenceEndDate,
    required this.hourlyRate,
    required this.onConfirm,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Confirm Booking', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: 'Tutor', value: tutorName, theme: theme),
                  _InfoRow(label: 'Date', value: '${slot.date.day}/${slot.date.month}/${slot.date.year}', theme: theme),
                  _InfoRow(label: 'Time', value: '${slot.startTime} - ${slot.endTime}', theme: theme),
                  _InfoRow(label: 'Rate', value: '\$${hourlyRate.toStringAsFixed(0)}/lesson', theme: theme),
                  if (recurrenceType != RecurrenceType.none) ...[
                    _InfoRow(label: 'Recurrence', value: recurrenceType == RecurrenceType.weekly ? 'Weekly' : 'Biweekly', theme: theme),
                    if (recurrenceEndDate != null)
                      _InfoRow(label: 'Until', value: '${recurrenceEndDate!.day}/${recurrenceEndDate!.month}/${recurrenceEndDate!.year}', theme: theme),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onConfirm,
              child: const Text('Confirm Booking'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoRow({required this.label, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class BookingSuccessStep extends StatelessWidget {
  final VoidCallback onViewBookings;
  final VoidCallback onDone;
  final ThemeData theme;

  const BookingSuccessStep({super.key, required this.onViewBookings, required this.onDone, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('Booking Confirmed!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Your lesson has been booked successfully.', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(onPressed: onViewBookings, child: const Text('View My Bookings')),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onDone, child: const Text('Done')),
        ],
      ),
    );
  }
}
