import 'package:education/data/reviews/review.dart';
import 'package:education/data/reviews/review_repository.dart';

class MockReviewRepository implements ReviewRepository {
  final List<Review> _reviews = [
    Review(
      reviewId: 'rev-1',
      tutorId: 'tutor-1',
      studentId: 'student-1',
      studentName: 'Alex Rivera',
      rating: 5,
      comment: 'Amazing tutor! Very patient and explains concepts clearly. My IELTS score improved significantly.',
      date: DateTime(2026, 1),
    ),
    Review(
      reviewId: 'rev-2',
      tutorId: 'tutor-1',
      studentId: 'student-2',
      studentName: 'Yuki T.',
      rating: 5,
      comment: 'Great lessons with practical exercises. Highly recommend for business English.',
      date: DateTime(2025, 12),
    ),
    Review(
      reviewId: 'rev-3',
      tutorId: 'tutor-1',
      studentId: 'student-3',
      studentName: 'Ahmed K.',
      rating: 4,
      comment: 'Very professional and well-prepared for each lesson. Flexible with scheduling too.',
      date: DateTime(2025, 11),
    ),
    Review(
      reviewId: 'rev-4',
      tutorId: 'tutor-2',
      studentId: 'student-1',
      studentName: 'Alex Rivera',
      rating: 5,
      comment: 'Michael makes calculus so much easier to understand. Excellent teacher!',
      date: DateTime(2026, 1),
    ),
    Review(
      reviewId: 'rev-5',
      tutorId: 'tutor-3',
      studentId: 'student-2',
      studentName: 'Yuki T.',
      rating: 4,
      comment: 'Elena is a wonderful piano teacher. Very encouraging and patient.',
      date: DateTime(2025, 12),
    ),
  ];

  @override
  Future<List<Review>> getReviewsForTutor(String tutorId) async {
    return _reviews.where((r) => r.tutorId == tutorId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<Review> submitReview(Review review) async {
    _reviews.add(review);
    return review;
  }
}
