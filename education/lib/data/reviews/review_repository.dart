import 'package:education/data/reviews/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getReviewsForTutor(String tutorId);
  Future<Review> submitReview(Review review);
}
