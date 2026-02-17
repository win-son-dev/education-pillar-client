import 'package:centralized_library/centralized_library.dart';

abstract class TutorProfileEvent extends Equatable {
  const TutorProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadTutorProfile extends TutorProfileEvent {
  final String tutorId;
  const LoadTutorProfile(this.tutorId);
  @override
  List<Object?> get props => [tutorId];
}
