import 'package:flutter/material.dart';
import 'package:education/data/bookings/booking.dart';
import 'package:education/data/reviews/review.dart';

class TodayScheduleCard extends StatelessWidget {
  final List<Booking> todayBookings;
  final ThemeData theme;

  const TodayScheduleCard({super.key, required this.todayBookings, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Schedule", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (todayBookings.isEmpty)
              Text('No lessons today', style: theme.textTheme.bodyMedium)
            else
              ...todayBookings.map((b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text('${b.startTime} - ${b.endTime}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text('Student ${b.studentId}', style: theme.textTheme.bodySmall),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}

class PendingBookingsCard extends StatelessWidget {
  final int pendingCount;
  final VoidCallback? onTap;
  final ThemeData theme;

  const PendingBookingsCard({super.key, required this.pendingCount, this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.pending_actions, size: 32, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pending Bookings', style: theme.textTheme.titleSmall),
                    Text('$pendingCount awaiting confirmation', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class EarningsSummary extends StatelessWidget {
  final int totalLessons;
  final double hourlyRate;
  final ThemeData theme;

  const EarningsSummary({super.key, required this.totalLessons, required this.hourlyRate, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Earnings Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('$totalLessons', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Total Lessons', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text('\$${(totalLessons * hourlyRate).toStringAsFixed(0)}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Total Earned', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RecentReviewsCard extends StatelessWidget {
  final List<Review> reviews;
  final ThemeData theme;

  const RecentReviewsCard({super.key, required this.reviews, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Reviews', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...reviews.take(3).map((r) => Card(
            child: ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 14, color: Colors.amber)),
              ),
              title: Text(r.studentName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text(r.comment, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          )),
        ],
      ),
    );
  }
}
