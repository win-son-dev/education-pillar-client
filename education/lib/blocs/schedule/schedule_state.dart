import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/schedules/schedule_slot.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();
  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleSlot> slots;
  final bool hasUnsavedChanges;

  const ScheduleLoaded({required this.slots, this.hasUnsavedChanges = false});

  @override
  List<Object?> get props => [slots, hasUnsavedChanges];
}

class ScheduleSaved extends ScheduleState {}

class ScheduleError extends ScheduleState {
  final String message;
  const ScheduleError(this.message);
  @override
  List<Object?> get props => [message];
}
