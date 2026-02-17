import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/booking/booking_bloc.dart';
import 'package:education/blocs/booking/booking_state.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_bloc.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_event.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_state.dart';
import 'package:education/data/bookings/booking.dart';
import 'package:education/presentations/dashboard/student/student_dashboard_sections.dart';
import 'package:education/presentations/tutor_listing/tutor_listing_sections.dart';

class DesktopStudentDashboard extends StatelessWidget {
  const DesktopStudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: search + suggested tutors
              Expanded(
                flex: 2,
                child: ListView(
                  padding: const EdgeInsets.only(top: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search tutors...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (query) {
                          context.read<TutorDiscoveryBloc>().add(FilterTutors(query: query));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Row(
                        children: [
                          Text('Suggested Tutors', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/tutors'),
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                    ),
                    BlocBuilder<TutorDiscoveryBloc, TutorDiscoveryState>(
                      builder: (context, state) {
                        if (state is TutorDiscoveryLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (state is TutorDiscoveryLoaded) {
                          final tutors = state.tutors.take(5).toList();
                          if (tutors.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(child: Text('No tutors found', style: theme.textTheme.bodyMedium)),
                            );
                          }
                          return Column(
                            children: tutors.map((tutor) => TutorListCard(
                              tutor: tutor,
                              theme: theme,
                              onTap: () => context.push('/tutor/${tutor.userId}'),
                            )).toList(),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              // Right column: upcoming + quick actions + recent
              Expanded(
                child: BlocBuilder<BookingBloc, BookingState>(
                  builder: (context, state) {
                    final bookings = state is BookingsLoaded ? state.bookings : <Booking>[];
                    final upcoming = bookings.where((b) => b.date.isAfter(DateTime.now()) && b.status != BookingStatus.cancelled).toList()
                      ..sort((a, b) => a.date.compareTo(b.date));

                    return ListView(
                      padding: const EdgeInsets.only(top: 8),
                      children: [
                        UpcomingLessonCard(nextBooking: upcoming.isNotEmpty ? upcoming.first : null, tutorName: upcoming.isNotEmpty ? 'Tutor ${upcoming.first.tutorId}' : '', theme: theme),
                        QuickActions(theme: theme),
                        RecentActivityList(recentBookings: bookings.where((b) => b.status == BookingStatus.completed).toList(), theme: theme),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
