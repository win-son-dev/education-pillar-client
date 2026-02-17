import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/booking/booking_bloc.dart';
import 'package:education/blocs/messaging/messaging_bloc.dart';
import 'package:education/blocs/messaging/messaging_event.dart';
import 'package:education/blocs/review/review_bloc.dart';
import 'package:education/blocs/schedule/schedule_bloc.dart';
import 'package:education/blocs/schedule/schedule_event.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_bloc.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_event.dart';
import 'package:education/blocs/tutor_profile/tutor_profile_bloc.dart';
import 'package:education/blocs/tutor_profile/tutor_profile_event.dart';
import 'package:education/data/bookings/booking_repository.dart';
import 'package:education/data/messages/message_repository.dart';
import 'package:education/data/reviews/review_repository.dart';
import 'package:education/data/users/student_repository.dart';
import 'package:education/data/users/tutor_repository.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/di/service_locator.dart';
import 'package:education/layout/responsive_layout.dart';

import 'package:education/presentations/shell/app_shell.dart';
import 'package:education/presentations/tutor_listing/mobile_tutor_listing_page.dart';
import 'package:education/presentations/tutor_listing/tablet_tutor_listing_page.dart';
import 'package:education/presentations/tutor_listing/desktop_tutor_listing_page.dart';
import 'package:education/presentations/tutors/mobile_tutor_page.dart';
import 'package:education/presentations/tutors/tablet_tutor_page.dart';
import 'package:education/presentations/tutors/desktop_tutor_page.dart';
import 'package:education/presentations/booking/booking_flow_page.dart';
import 'package:education/presentations/bookings/mobile_bookings_page.dart';
import 'package:education/presentations/bookings/tablet_bookings_page.dart';
import 'package:education/presentations/bookings/desktop_bookings_page.dart';
import 'package:education/presentations/students/mobile_student_page.dart';
import 'package:education/presentations/students/tablet_student_page.dart';
import 'package:education/presentations/students/desktop_student_page.dart';
import 'package:education/presentations/messaging/mobile_conversations_page.dart';
import 'package:education/presentations/messaging/tablet_conversations_page.dart';
import 'package:education/presentations/messaging/desktop_conversations_page.dart';
import 'package:education/presentations/messaging/chat_page.dart';
import 'package:education/presentations/notifications/mobile_notifications_page.dart';
import 'package:education/presentations/notifications/tablet_notifications_page.dart';
import 'package:education/presentations/notifications/desktop_notifications_page.dart';
import 'package:education/presentations/reviews/review_submit_page.dart';
import 'package:education/presentations/dashboard/student/mobile_student_dashboard.dart';
import 'package:education/presentations/dashboard/student/tablet_student_dashboard.dart';
import 'package:education/presentations/dashboard/student/desktop_student_dashboard.dart';
import 'package:education/presentations/dashboard/tutor/mobile_tutor_dashboard.dart';
import 'package:education/presentations/dashboard/tutor/tablet_tutor_dashboard.dart';
import 'package:education/presentations/dashboard/tutor/desktop_tutor_dashboard.dart';
import 'package:education/presentations/schedule/mobile_schedule_page.dart';
import 'package:education/presentations/schedule/tablet_schedule_page.dart';
import 'package:education/presentations/schedule/desktop_schedule_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home/student',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // Home (was Dashboard)
        GoRoute(
          path: '/home/student',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => TutorDiscoveryBloc(tutorRepository: sl<TutorRepository>())..add(LoadTutors()),
              child: const ResponsiveLayout(
                mobileBody: MobileStudentDashboard(),
                tabletBody: TabletStudentDashboard(),
                desktopBody: DesktopStudentDashboard(),
              ),
            );
          },
        ),
        GoRoute(
          path: '/home/tutor',
          builder: (context, state) {
            return const ResponsiveLayout(
              mobileBody: MobileTutorDashboard(),
              tabletBody: TabletTutorDashboard(),
              desktopBody: DesktopTutorDashboard(),
            );
          },
        ),

        // Tutor Listing (student searches for tutors)
        GoRoute(
          path: '/tutors',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => TutorDiscoveryBloc(tutorRepository: sl<TutorRepository>())..add(LoadTutors()),
              child: const ResponsiveLayout(
                mobileBody: MobileTutorListingPage(),
                tabletBody: TabletTutorListingPage(),
                desktopBody: DesktopTutorListingPage(),
              ),
            );
          },
        ),

        // Schedule (bookings calendar - own tab)
        GoRoute(
          path: '/schedule',
          builder: (context, state) {
            return const ResponsiveLayout(
              mobileBody: MobileBookingsPage(),
              tabletBody: TabletBookingsPage(),
              desktopBody: DesktopBookingsPage(),
            );
          },
        ),

        // Messages
        GoRoute(
          path: '/messages',
          builder: (context, state) {
            return BlocProvider(
              create: (_) => MessagingBloc(
                messageRepository: sl<MessageRepository>(),
                currentUserService: sl<CurrentUserService>(),
              )..add(LoadRooms()),
              child: const ResponsiveLayout(
                mobileBody: MobileConversationsPage(),
                tabletBody: TabletConversationsPage(),
                desktopBody: DesktopConversationsPage(),
              ),
            );
          },
        ),

        // Notifications
        GoRoute(
          path: '/notifications',
          builder: (context, state) {
            return const ResponsiveLayout(
              mobileBody: MobileNotificationsPage(),
              tabletBody: TabletNotificationsPage(),
              desktopBody: DesktopNotificationsPage(),
            );
          },
        ),

        // Tutor Availability Management
        GoRoute(
          path: '/availability',
          builder: (context, state) {
            final currentUser = sl<CurrentUserService>();
            return BlocProvider(
              create: (_) => ScheduleBloc(tutorRepository: sl<TutorRepository>())..add(LoadSchedule(currentUser.userId)),
              child: const ResponsiveLayout(
                mobileBody: MobileSchedulePage(),
                tabletBody: TabletSchedulePage(),
                desktopBody: DesktopSchedulePage(),
              ),
            );
          },
        ),
      ],
    ),

    // Tutor Profile (outside shell for back navigation)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/tutor/:tutorId',
      builder: (context, state) {
        final tutorId = state.pathParameters['tutorId']!;
        return BlocProvider(
          create: (_) => TutorProfileBloc(
            tutorRepository: sl<TutorRepository>(),
            reviewRepository: sl<ReviewRepository>(),
          )..add(LoadTutorProfile(tutorId)),
          child: const ResponsiveLayout(
            mobileBody: MobileTutorPage(),
            tabletBody: TabletTutorPage(),
            desktopBody: DesktopTutorPage(),
          ),
        );
      },
    ),

    // Booking Flow
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/book/:tutorId',
      builder: (context, state) {
        final tutorId = state.pathParameters['tutorId']!;
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => TutorProfileBloc(
                tutorRepository: sl<TutorRepository>(),
                reviewRepository: sl<ReviewRepository>(),
              )..add(LoadTutorProfile(tutorId)),
            ),
            BlocProvider(
              create: (_) => BookingBloc(
                bookingRepository: sl<BookingRepository>(),
                currentUserService: sl<CurrentUserService>(),
              ),
            ),
          ],
          child: const BookingFlowPage(),
        );
      },
    ),

    // Student Profile
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/student/:studentId',
      builder: (context, state) {
        final studentId = state.pathParameters['studentId']!;
        return FutureBuilder(
          future: Future.wait([
            sl<StudentRepository>().getStudentById(studentId),
            sl<BookingRepository>().getBookingsForStudent(studentId),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final student = snapshot.data![0];
            final bookings = snapshot.data![1];
            if (student == null) {
              return const Scaffold(body: Center(child: Text('Student not found')));
            }
            return ResponsiveLayout(
              mobileBody: MobileStudentPage(student: student as dynamic, bookings: bookings as dynamic),
              tabletBody: TabletStudentPage(student: student as dynamic, bookings: bookings as dynamic),
              desktopBody: DesktopStudentPage(student: student as dynamic, bookings: bookings as dynamic),
            );
          },
        );
      },
    ),

    // Chat (mobile standalone)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/chat/:roomId',
      builder: (context, state) {
        final roomId = state.pathParameters['roomId']!;
        return BlocProvider(
          create: (_) => MessagingBloc(
            messageRepository: sl<MessageRepository>(),
            currentUserService: sl<CurrentUserService>(),
          )..add(LoadMessages(roomId)),
          child: ChatPage(roomId: roomId),
        );
      },
    ),

    // Review Submit
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/review/:bookingId',
      builder: (context, state) {
        final bookingId = state.pathParameters['bookingId']!;
        final tutorId = state.uri.queryParameters['tutorId'] ?? '';
        return BlocProvider(
          create: (_) => ReviewBloc(reviewRepository: sl<ReviewRepository>()),
          child: ReviewSubmitPage(bookingId: bookingId, tutorId: tutorId),
        );
      },
    ),

    // Fullscreen video
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/fullscreen-video',
      builder: (context, state) {
        final config = state.extra as VideoConfig;
        return FullscreenVideoPlayer(config: config);
      },
    ),
  ],
);
