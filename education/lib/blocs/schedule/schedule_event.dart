import 'package:centralized_library/centralized_library.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();
  @override
  List<Object?> get props => [];
}

class LoadSchedule extends ScheduleEvent {
  final String tutorId;
  const LoadSchedule(this.tutorId);
  @override
  List<Object?> get props => [tutorId];
}

class ToggleSlot extends ScheduleEvent {
  final String slotId;
  const ToggleSlot(this.slotId);
  @override
  List<Object?> get props => [slotId];
}

class SaveSchedule extends ScheduleEvent {}
