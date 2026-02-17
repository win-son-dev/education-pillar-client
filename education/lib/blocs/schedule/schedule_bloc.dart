import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/users/tutor_repository.dart';
import 'package:education/blocs/schedule/schedule_event.dart';
import 'package:education/blocs/schedule/schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final TutorRepository _tutorRepository;

  ScheduleBloc({required TutorRepository tutorRepository})
      : _tutorRepository = tutorRepository,
        super(ScheduleInitial()) {
    on<LoadSchedule>(_onLoadSchedule);
    on<ToggleSlot>(_onToggleSlot);
    on<SaveSchedule>(_onSaveSchedule);
  }

  Future<void> _onLoadSchedule(LoadSchedule event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    try {
      final slots = await _tutorRepository.getAvailableSlots(event.tutorId);
      emit(ScheduleLoaded(slots: slots));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  void _onToggleSlot(ToggleSlot event, Emitter<ScheduleState> emit) {
    final currentState = state;
    if (currentState is! ScheduleLoaded) return;

    final slots = currentState.slots.map((slot) {
      if (slot.slotId == event.slotId) {
        return slot.copyWith(isBooked: !slot.isBooked);
      }
      return slot;
    }).toList();

    emit(ScheduleLoaded(slots: slots, hasUnsavedChanges: true));
  }

  Future<void> _onSaveSchedule(SaveSchedule event, Emitter<ScheduleState> emit) async {
    final currentState = state;
    if (currentState is! ScheduleLoaded) return;

    try {
      for (final slot in currentState.slots) {
        await _tutorRepository.updateSlot(slot);
      }
      emit(ScheduleLoaded(slots: currentState.slots, hasUnsavedChanges: false));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }
}
