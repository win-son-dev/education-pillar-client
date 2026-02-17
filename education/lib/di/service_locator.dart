import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/bookings/booking_repository.dart';
import 'package:education/data/bookings/mocks/mock_booking_repository.dart';
import 'package:education/data/messages/message_repository.dart';
import 'package:education/data/messages/mocks/mock_message_repository.dart';
import 'package:education/data/notifications/mocks/mock_notification_repository.dart';
import 'package:education/data/notifications/notification_repository.dart';
import 'package:education/data/reviews/mocks/mock_review_repository.dart';
import 'package:education/data/reviews/review_repository.dart';
import 'package:education/data/users/mocks/mock_student_repository.dart';
import 'package:education/data/users/mocks/mock_tutor_repository.dart';
import 'package:education/data/users/student_repository.dart';
import 'package:education/data/users/tutor_repository.dart';
import 'package:education/di/current_user_service.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<CurrentUserService>(() => CurrentUserService());
  sl.registerLazySingleton<TutorRepository>(() => MockTutorRepository());
  sl.registerLazySingleton<StudentRepository>(() => MockStudentRepository());
  sl.registerLazySingleton<BookingRepository>(() => MockBookingRepository());
  sl.registerLazySingleton<ReviewRepository>(() => MockReviewRepository());
  sl.registerLazySingleton<MessageRepository>(() => MockMessageRepository());
  sl.registerLazySingleton<NotificationRepository>(() => MockNotificationRepository());
}
