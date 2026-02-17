import 'package:flutter/material.dart';
import 'package:education/data/schedules/schedule_slot.dart';

class WeeklyScheduleGrid extends StatelessWidget {
  final List<ScheduleSlot> slots;
  final ValueChanged<String> onToggleSlot;
  final ThemeData theme;

  const WeeklyScheduleGrid({super.key, required this.slots, required this.onToggleSlot, required this.theme});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _timeSlots = ['9 AM', '12 PM', '3 PM', '6 PM'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Schedule', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Table(
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
                          final isAvailable = slot != null && !slot.isBooked;
                          return GestureDetector(
                            onTap: slot != null ? () => onToggleSlot(slot.slotId) : null,
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? theme.colorScheme.primaryContainer
                                    : slot?.isBooked == true
                                        ? theme.colorScheme.errorContainer
                                        : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isAvailable ? theme.colorScheme.primary : Colors.transparent,
                                  width: isAvailable ? 1.5 : 0,
                                ),
                              ),
                              child: Center(
                                child: slot?.isBooked == true
                                    ? Icon(Icons.block, size: 14, color: theme.colorScheme.error)
                                    : isAvailable
                                        ? Icon(Icons.check, size: 14, color: theme.colorScheme.primary)
                                        : null,
                              ),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Legend(color: theme.colorScheme.primaryContainer, label: 'Available', theme: theme),
              const SizedBox(width: 16),
              _Legend(color: theme.colorScheme.errorContainer, label: 'Booked', theme: theme),
              const SizedBox(width: 16),
              _Legend(color: theme.colorScheme.surfaceContainerHighest, label: 'Unavailable', theme: theme),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final ThemeData theme;

  const _Legend({required this.color, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
