import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/users/tutor_profile.dart';

abstract class TutorDiscoveryState extends Equatable {
  const TutorDiscoveryState();
  @override
  List<Object?> get props => [];
}

class TutorDiscoveryInitial extends TutorDiscoveryState {}

class TutorDiscoveryLoading extends TutorDiscoveryState {}

class TutorDiscoveryLoaded extends TutorDiscoveryState {
  final List<TutorProfile> tutors;
  final List<TutorProfile> allTutors;

  const TutorDiscoveryLoaded({required this.tutors, required this.allTutors});

  @override
  List<Object?> get props => [tutors, allTutors];
}

class TutorDiscoveryError extends TutorDiscoveryState {
  final String message;
  const TutorDiscoveryError(this.message);
  @override
  List<Object?> get props => [message];
}
