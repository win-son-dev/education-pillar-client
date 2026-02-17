import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/bookings/booking.dart';
import 'package:education/data/users/student_profile.dart';

class StudentProfileHeader extends StatelessWidget {
  final StudentProfile student;
  final ThemeData theme;

  const StudentProfileHeader({super.key, required this.student, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            child: ClipOval(
              child: student.profileImageUrl != null
                  ? NetworkImageCard(
                      imageUrl: student.profileImageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            student.name,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (student.location != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(width: 4),
                Text(student.location!, style: theme.textTheme.bodyMedium),
              ],
            ),
          if (student.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(student.bio, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

class LearningGoals extends StatelessWidget {
  final List<String> goals;
  final ThemeData theme;

  const LearningGoals({super.key, required this.goals, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Learning Goals', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: goals.map((g) => Chip(label: Text(g))).toList(),
          ),
        ],
      ),
    );
  }
}

class UpcomingBookingsSection extends StatelessWidget {
  final List<Booking> bookings;
  final ThemeData theme;

  const UpcomingBookingsSection({super.key, required this.bookings, required this.theme});

  @override
  Widget build(BuildContext context) {
    final upcoming = bookings
        .where((b) => b.date.isAfter(DateTime.now()) && b.status != BookingStatus.cancelled)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Bookings', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...upcoming.take(3).map((b) => Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('${b.date.day}/${b.date.month}/${b.date.year} at ${b.startTime}'),
              subtitle: Text('Status: ${b.status.name}'),
            ),
          )),
        ],
      ),
    );
  }
}

class StudentLanguagesSection extends StatelessWidget {
  final List<String> languages;
  final ThemeData theme;

  const StudentLanguagesSection({super.key, required this.languages, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (languages.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Languages', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: languages.map((l) => Chip(label: Text(l))).toList(),
          ),
        ],
      ),
    );
  }
}
