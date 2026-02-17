import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/reviews/review.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  const ReviewsLoaded(this.reviews);
  @override
  List<Object?> get props => [reviews];
}

class ReviewSubmitted extends ReviewState {
  final Review review;
  const ReviewSubmitted(this.review);
  @override
  List<Object?> get props => [review];
}

class ReviewError extends ReviewState {
  final String message;
  const ReviewError(this.message);
  @override
  List<Object?> get props => [message];
}
