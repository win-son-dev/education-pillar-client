import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/bookings/booking.dart';

class UpcomingLessonCard extends StatelessWidget {
  final Booking? nextBooking;
  final String tutorName;
  final ThemeData theme;

  const UpcomingLessonCard({super.key, this.nextBooking, required this.tutorName, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (nextBooking == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.calendar_today, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 8),
              Text('No upcoming lessons', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Find a tutor to get started!', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Next Lesson', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(tutorName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 4),
                Text('${nextBooking!.date.day}/${nextBooking!.date.month}/${nextBooking!.date.year}', style: theme.textTheme.bodyMedium),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 14),
                const SizedBox(width: 4),
                Text(nextBooking!.startTime, style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActions extends StatelessWidget {
  final ThemeData theme;

  const QuickActions({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ActionCard(icon: Icons.search, label: 'Find Tutor', onTap: () => context.go('/tutors'), theme: theme)),
              const SizedBox(width: 8),
              Expanded(child: _ActionCard(icon: Icons.calendar_month, label: 'Schedule', onTap: () => context.go('/schedule'), theme: theme)),
              const SizedBox(width: 8),
              Expanded(child: _ActionCard(icon: Icons.message, label: 'Messages', onTap: () => context.go('/messages'), theme: theme)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ActionCard({required this.icon, required this.label, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(label, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentActivityList extends StatelessWidget {
  final List<Booking> recentBookings;
  final ThemeData theme;

  const RecentActivityList({super.key, required this.recentBookings, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (recentBookings.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Activity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...recentBookings.take(5).map((b) => ListTile(
            leading: Icon(
              b.status == BookingStatus.completed ? Icons.check_circle : Icons.calendar_today,
              color: b.status == BookingStatus.completed ? Colors.green : null,
            ),
            title: Text('Lesson on ${b.date.day}/${b.date.month}'),
            subtitle: Text('${b.startTime} - ${b.status.name}'),
          )),
        ],
      ),
    );
  }
}
