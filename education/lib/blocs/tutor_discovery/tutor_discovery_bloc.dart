import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/users/tutor_repository.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_event.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_state.dart';

class TutorDiscoveryBloc extends Bloc<TutorDiscoveryEvent, TutorDiscoveryState> {
  final TutorRepository _tutorRepository;

  TutorDiscoveryBloc({required TutorRepository tutorRepository})
      : _tutorRepository = tutorRepository,
        super(TutorDiscoveryInitial()) {
    on<LoadTutors>(_onLoadTutors);
    on<FilterTutors>(_onFilterTutors);
  }

  Future<void> _onLoadTutors(LoadTutors event, Emitter<TutorDiscoveryState> emit) async {
    emit(TutorDiscoveryLoading());
    try {
      final tutors = await _tutorRepository.getTutors();
      emit(TutorDiscoveryLoaded(tutors: tutors, allTutors: tutors));
    } catch (e) {
      emit(TutorDiscoveryError(e.toString()));
    }
  }

  void _onFilterTutors(FilterTutors event, Emitter<TutorDiscoveryState> emit) {
    final currentState = state;
    if (currentState is! TutorDiscoveryLoaded) return;

    var filtered = List.of(currentState.allTutors);

    if (event.query != null && event.query!.isNotEmpty) {
      final q = event.query!.toLowerCase();
      filtered = filtered.where((t) =>
        t.name.toLowerCase().contains(q) ||
        t.title.toLowerCase().contains(q) ||
        t.specializations.any((s) => s.toLowerCase().contains(q))
      ).toList();
    }

    if (event.specialization != null && event.specialization!.isNotEmpty) {
      filtered = filtered.where((t) =>
        t.specializations.contains(event.specialization)
      ).toList();
    }

    if (event.maxPrice != null) {
      filtered = filtered.where((t) => t.hourlyRate <= event.maxPrice!).toList();
    }

    emit(TutorDiscoveryLoaded(tutors: filtered, allTutors: currentState.allTutors));
  }
}
