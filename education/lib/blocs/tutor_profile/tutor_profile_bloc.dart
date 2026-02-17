import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/certifications/certification.dart';
import 'package:education/data/reviews/review.dart';
import 'package:education/data/reviews/review_repository.dart';
import 'package:education/data/schedules/schedule_slot.dart';
import 'package:education/data/users/tutor_repository.dart';
import 'package:education/blocs/tutor_profile/tutor_profile_event.dart';
import 'package:education/blocs/tutor_profile/tutor_profile_state.dart';

class TutorProfileBloc extends Bloc<TutorProfileEvent, TutorProfileState> {
  final TutorRepository _tutorRepository;
  final ReviewRepository _reviewRepository;

  TutorProfileBloc({
    required TutorRepository tutorRepository,
    required ReviewRepository reviewRepository,
  })  : _tutorRepository = tutorRepository,
        _reviewRepository = reviewRepository,
        super(TutorProfileInitial()) {
    on<LoadTutorProfile>(_onLoadTutorProfile);
  }

  Future<void> _onLoadTutorProfile(
    LoadTutorProfile event,
    Emitter<TutorProfileState> emit,
  ) async {
    emit(TutorProfileLoading());
    try {
      final tutor = await _tutorRepository.getTutorById(event.tutorId);
      if (tutor == null) {
        emit(const TutorProfileError('Tutor not found'));
        return;
      }

      final results = await Future.wait([
        _tutorRepository.getCertifications(event.tutorId),
        _tutorRepository.getAvailableSlots(event.tutorId),
        _reviewRepository.getReviewsForTutor(event.tutorId),
      ]);

      emit(TutorProfileLoaded(
        tutor: tutor,
        certifications: results[0] as List<Certification>,
        slots: results[1] as List<ScheduleSlot>,
        reviews: results[2] as List<Review>,
      ));
    } catch (e) {
      emit(TutorProfileError(e.toString()));
    }
  }
}
