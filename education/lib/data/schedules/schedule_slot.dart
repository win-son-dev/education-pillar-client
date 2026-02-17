import 'package:centralized_library/centralized_library.dart';

class ScheduleSlot extends Equatable {
  final String slotId;
  final String tutorId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final bool isBooked;

  const ScheduleSlot({
    required this.slotId,
    required this.tutorId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });

  @override
  List<Object?> get props => [
    slotId,
    tutorId,
    date,
    startTime,
    endTime,
    isBooked,
  ];

  ScheduleSlot copyWith({
    DateTime? date,
    String? startTime,
    String? endTime,
    bool? isBooked,
  }) {
    return ScheduleSlot(
      slotId: slotId,
      tutorId: tutorId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
    );
  }
}
