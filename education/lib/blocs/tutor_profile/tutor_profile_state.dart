import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/certifications/certification.dart';
import 'package:education/data/reviews/review.dart';
import 'package:education/data/schedules/schedule_slot.dart';
import 'package:education/data/users/tutor_profile.dart';

abstract class TutorProfileState extends Equatable {
  const TutorProfileState();
  @override
  List<Object?> get props => [];
}

class TutorProfileInitial extends TutorProfileState {}

class TutorProfileLoading extends TutorProfileState {}

class TutorProfileLoaded extends TutorProfileState {
  final TutorProfile tutor;
  final List<Certification> certifications;
  final List<Review> reviews;
  final List<ScheduleSlot> slots;

  const TutorProfileLoaded({
    required this.tutor,
    required this.certifications,
    required this.reviews,
    required this.slots,
  });

  @override
  List<Object?> get props => [tutor, certifications, reviews, slots];
}

class TutorProfileError extends TutorProfileState {
  final String message;
  const TutorProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
