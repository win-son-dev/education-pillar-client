import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/booking/booking_bloc.dart';
import 'package:education/blocs/booking/booking_state.dart';
import 'package:education/blocs/review/review_bloc.dart';
import 'package:education/blocs/review/review_state.dart';
import 'package:education/data/bookings/booking.dart';
import 'package:education/data/reviews/review.dart';
import 'package:education/presentations/dashboard/tutor/tutor_dashboard_sections.dart';

class TabletTutorDashboard extends StatelessWidget {
  const TabletTutorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, bookingState) {
          final bookings = bookingState is BookingsLoaded ? bookingState.bookings : <Booking>[];
          final todayBookings = bookings.where((b) =>
            b.date.year == now.year && b.date.month == now.month && b.date.day == now.day &&
            b.status == BookingStatus.confirmed
          ).toList();
          final pendingCount = bookings.where((b) => b.status == BookingStatus.pending).length;
          final completedCount = bookings.where((b) => b.status == BookingStatus.completed).length;

          return BlocBuilder<ReviewBloc, ReviewState>(
            builder: (context, reviewState) {
              final reviews = reviewState is ReviewsLoaded ? reviewState.reviews : <Review>[];

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: ListView(children: [
                    TodayScheduleCard(todayBookings: todayBookings, theme: theme),
                    PendingBookingsCard(pendingCount: pendingCount, theme: theme, onTap: () => context.go('/schedule')),
                  ])),
                  Expanded(child: ListView(children: [
                    EarningsSummary(totalLessons: completedCount, hourlyRate: 26.0, theme: theme),
                    RecentReviewsCard(reviews: reviews, theme: theme),
                  ])),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
