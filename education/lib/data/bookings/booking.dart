import 'package:centralized_library/centralized_library.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

enum RecurrenceType { none, weekly, biweekly }

class Booking extends Equatable {
  final String bookingId;
  final String tutorId;
  final String studentId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final BookingStatus status;
  final String? recurrenceGroupId;
  final RecurrenceType recurrenceType;
  final DateTime? recurrenceEndDate;
  final String? cancellationReason;
  final DateTime createdAt;

  const Booking({
    required this.bookingId,
    required this.tutorId,
    required this.studentId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = BookingStatus.pending,
    this.recurrenceGroupId,
    this.recurrenceType = RecurrenceType.none,
    this.recurrenceEndDate,
    this.cancellationReason,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    bookingId,
    tutorId,
    studentId,
    date,
    startTime,
    endTime,
    status,
    recurrenceGroupId,
    recurrenceType,
    recurrenceEndDate,
    cancellationReason,
    createdAt,
  ];

  Booking copyWith({
    DateTime? date,
    String? startTime,
    String? endTime,
    BookingStatus? status,
    String? recurrenceGroupId,
    RecurrenceType? recurrenceType,
    DateTime? recurrenceEndDate,
    String? cancellationReason,
  }) {
    return Booking(
      bookingId: bookingId,
      tutorId: tutorId,
      studentId: studentId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      recurrenceGroupId: recurrenceGroupId ?? this.recurrenceGroupId,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt,
    );
  }
}
