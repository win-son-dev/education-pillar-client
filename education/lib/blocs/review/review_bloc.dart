import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/reviews/review_repository.dart';
import 'package:education/blocs/review/review_event.dart';
import 'package:education/blocs/review/review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository _reviewRepository;

  ReviewBloc({required ReviewRepository reviewRepository})
      : _reviewRepository = reviewRepository,
        super(ReviewInitial()) {
    on<LoadReviews>(_onLoadReviews);
    on<SubmitReview>(_onSubmitReview);
  }

  Future<void> _onLoadReviews(LoadReviews event, Emitter<ReviewState> emit) async {
    emit(ReviewLoading());
    try {
      final reviews = await _reviewRepository.getReviewsForTutor(event.tutorId);
      emit(ReviewsLoaded(reviews));
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }

  Future<void> _onSubmitReview(SubmitReview event, Emitter<ReviewState> emit) async {
    emit(ReviewLoading());
    try {
      final review = await _reviewRepository.submitReview(event.review);
      emit(ReviewSubmitted(review));
    } catch (e) {
      emit(ReviewError(e.toString()));
    }
  }
}
