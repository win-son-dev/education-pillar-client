import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/booking/booking_bloc.dart';
import 'package:education/blocs/booking/booking_event.dart';
import 'package:education/blocs/messaging/messaging_bloc.dart';
import 'package:education/blocs/messaging/messaging_event.dart';
import 'package:education/blocs/notification/notification_bloc.dart';
import 'package:education/blocs/notification/notification_event.dart';
import 'package:education/blocs/review/review_bloc.dart';
import 'package:education/data/bookings/booking_repository.dart';
import 'package:education/data/messages/message_repository.dart';
import 'package:education/data/notifications/notification_repository.dart';
import 'package:education/data/reviews/review_repository.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/di/service_locator.dart';
import 'package:education/providers/theme_provider.dart';
import 'package:education/routes/app_router.dart';

class EducationApp extends StatelessWidget {
  const EducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider.instance),
      ],
      builder: (context, widget) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => BookingBloc(
                bookingRepository: sl<BookingRepository>(),
                currentUserService: sl<CurrentUserService>(),
              )..add(LoadBookings()),
            ),
            BlocProvider(
              create: (_) => MessagingBloc(
                messageRepository: sl<MessageRepository>(),
                currentUserService: sl<CurrentUserService>(),
              )..add(LoadRooms()),
            ),
            BlocProvider(
              create: (_) => NotificationBloc(
                notificationRepository: sl<NotificationRepository>(),
                currentUserService: sl<CurrentUserService>(),
              )..add(LoadNotifications()),
            ),
            BlocProvider(
              create: (_) => ReviewBloc(
                reviewRepository: sl<ReviewRepository>(),
              ),
            ),
          ],
          child: MaterialApp.router(
            title: 'Education Platform',
            theme: Provider.of<ThemeProvider>(context).currentThemeData,
            routerConfig: appRouter,
          ),
        );
      },
    );
  }
}
