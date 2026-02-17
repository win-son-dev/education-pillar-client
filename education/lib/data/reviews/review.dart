import 'package:centralized_library/centralized_library.dart';

class Review extends Equatable {
  final String reviewId;
  final String tutorId;
  final String studentId;
  final String studentName;
  final String? studentImageUrl;
  final int rating;
  final String comment;
  final DateTime date;

  const Review({
    required this.reviewId,
    required this.tutorId,
    required this.studentId,
    required this.studentName,
    this.studentImageUrl,
    required this.rating,
    required this.comment,
    required this.date,
  });

  @override
  List<Object?> get props => [
    reviewId,
    tutorId,
    studentId,
    studentName,
    studentImageUrl,
    rating,
    comment,
    date,
  ];

  Review copyWith({
    String? studentName,
    String? studentImageUrl,
    int? rating,
    String? comment,
    DateTime? date,
  }) {
    return Review(
      reviewId: reviewId,
      tutorId: tutorId,
      studentId: studentId,
      studentName: studentName ?? this.studentName,
      studentImageUrl: studentImageUrl ?? this.studentImageUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
    );
  }
}
