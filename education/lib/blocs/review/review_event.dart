import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/reviews/review.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class LoadReviews extends ReviewEvent {
  final String tutorId;
  const LoadReviews(this.tutorId);
  @override
  List<Object?> get props => [tutorId];
}

class SubmitReview extends ReviewEvent {
  final Review review;
  const SubmitReview(this.review);
  @override
  List<Object?> get props => [review];
}
