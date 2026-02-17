import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/certifications/certification.dart';
import 'package:education/data/reviews/review.dart';
import 'package:education/data/schedules/schedule_slot.dart';
import 'package:education/data/users/tutor_profile.dart';

// ---------------------------------------------------------------------------
// 1. Profile Header
// ---------------------------------------------------------------------------
class TutorProfileHeader extends StatelessWidget {
  final TutorProfile tutor;
  final List<Review> reviews;
  final ThemeData theme;

  const TutorProfileHeader({super.key, required this.tutor, required this.reviews, required this.theme});

  @override
  Widget build(BuildContext context) {
    final averageRating = reviews.isEmpty ? 0.0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            child: ClipOval(
              child: tutor.profileImageUrl != null
                  ? NetworkImageCard(
                      imageUrl: tutor.profileImageUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tutor.name,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          if (tutor.title.isNotEmpty)
            Text(
              tutor.title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 4),
          if (tutor.location != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined, size: 16),
                const SizedBox(width: 4),
                Text(tutor.location!, style: theme.textTheme.bodyMedium),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 18),
              const SizedBox(width: 4),
              Text(averageRating.toStringAsFixed(1), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Text('${reviews.length} reviews', style: theme.textTheme.bodySmall),
              const SizedBox(width: 16),
              Text('${tutor.totalLessonsCompleted} lessons', style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Video Intro Card
// ---------------------------------------------------------------------------
class TutorVideoIntroCard extends StatelessWidget {
  final TutorProfile tutor;
  final ThemeData theme;

  const TutorVideoIntroCard({super.key, required this.tutor, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (tutor.videoIntroUrl == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              MediaLoader(
                config: MediaConfig.network(tutor.videoIntroUrl!),
                fit: BoxFit.cover,
              ),
              Container(color: Colors.black26),
              Center(
                child: IconButton.filled(
                  onPressed: () {
                    context.push(
                      '/fullscreen-video',
                      extra: VideoConfig.simple(url: tutor.videoIntroUrl!),
                    );
                  },
                  icon: const Icon(Icons.play_arrow, size: 36),


                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Quick Stats Row
// ---------------------------------------------------------------------------
class TutorQuickStatsRow extends StatelessWidget {
  final TutorProfile tutor;
  final List<Review> reviews;
  final ThemeData theme;

  const TutorQuickStatsRow({super.key, required this.tutor, required this.reviews, required this.theme});

  @override
  Widget build(BuildContext context) {
    final averageRating = reviews.isEmpty ? 0.0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: TutorStatCard(label: 'Per lesson', value: '\$${tutor.hourlyRate.toStringAsFixed(0)}', theme: theme)),
          const SizedBox(width: 8),
          Expanded(child: TutorStatCard(label: 'Lessons', value: '${tutor.totalLessonsCompleted}', theme: theme)),
          const SizedBox(width: 8),
          Expanded(child: TutorStatCard(label: 'Rating', value: averageRating.toStringAsFixed(1), theme: theme)),
        ],
      ),
    );
  }
}

class TutorStatCard extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const TutorStatCard({super.key, required this.label, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Book Trial CTA
// ---------------------------------------------------------------------------
class TutorBookTrialCta extends StatelessWidget {
  final ThemeData theme;
  final double hourlyRate;
  final VoidCallback? onBook;

  const TutorBookTrialCta({super.key, required this.theme, required this.hourlyRate, this.onBook});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onBook,
          child: Text('Book trial lesson — \$${hourlyRate.toStringAsFixed(0)}'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. About Me
// ---------------------------------------------------------------------------
class TutorAboutMeSection extends StatefulWidget {
  final String bio;
  final ThemeData theme;

  const TutorAboutMeSection({super.key, required this.bio, required this.theme});

  @override
  State<TutorAboutMeSection> createState() => _TutorAboutMeSectionState();
}

class _TutorAboutMeSectionState extends State<TutorAboutMeSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About me', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            widget.bio,
            maxLines: _expanded ? null : 4,
            overflow: _expanded ? null : TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          if (widget.bio.length > 200)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _expanded ? 'Show less' : 'Read more',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Specializations
// ---------------------------------------------------------------------------
class TutorSpecializationsSection extends StatelessWidget {
  final List<String> specializations;
  final ThemeData theme;

  const TutorSpecializationsSection({super.key, required this.specializations, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (specializations.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Specializations', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: specializations
                .map((s) => Chip(
                      label: Text(s),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Certifications
// ---------------------------------------------------------------------------
class TutorCertificationsSection extends StatelessWidget {
  final List<Certification> certifications;
  final ThemeData theme;

  const TutorCertificationsSection({super.key, required this.certifications, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (certifications.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Certifications', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...certifications.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    c.isVerified ? Icons.verified : null,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: theme.textTheme.bodyMedium),
                        Text(c.issuingOrganization, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. Languages
// ---------------------------------------------------------------------------
class TutorLanguagesSection extends StatelessWidget {
  final List<String> languages;
  final ThemeData theme;

  const TutorLanguagesSection({super.key, required this.languages, required this.theme});

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
            children: languages
                .map((l) => Chip(
                      label: Text(l),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 9. Schedule Preview
// ---------------------------------------------------------------------------
class TutorSchedulePreview extends StatelessWidget {
  final List<ScheduleSlot> slots;
  final ThemeData theme;

  const TutorSchedulePreview({super.key, required this.slots, required this.theme});

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _timeSlots = ['9 AM', '12 PM', '3 PM', '6 PM'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Schedule', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  const SizedBox(width: 48),
                  ..._days.map((d) => Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(d, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                      )),
                ],
              ),
              for (var i = 0; i < _timeSlots.length; i++)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(_timeSlots[i], style: theme.textTheme.labelSmall),
                    ),
                    for (var j = 0; j < _days.length; j++)
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: Builder(
                          builder: (context) {
                            final hasSlot = slots.any((s) =>
                                s.date.weekday == j + 1 &&
                                s.startTime == _timeSlots[i] &&
                                !s.isBooked);
                            return Container(
                              height: 28,
                              decoration: BoxDecoration(
                                color: hasSlot ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 10. Reviews
// ---------------------------------------------------------------------------
class TutorReviewsSection extends StatelessWidget {
  final List<Review> reviews;
  final ThemeData theme;

  const TutorReviewsSection({super.key, required this.reviews, required this.theme});

  @override
  Widget build(BuildContext context) {
    final averageRating = reviews.isEmpty ? 0.0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reviews', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < averageRating.floor();
                      final half = !filled && i < averageRating.ceil();
                      return Icon(
                        half ? Icons.star_half : (filled ? Icons.star : Icons.star_border),
                        size: 20,
                      );
                    }),
                  ),
                  Text('${reviews.length} reviews', style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reviews.map((review) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TutorReviewCard(review: review, theme: theme),
          )),
        ],
      ),
    );
  }
}

class TutorReviewCard extends StatelessWidget {
  final Review review;
  final ThemeData theme;

  const TutorReviewCard({
    super.key,
    required this.review,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${monthNames[review.date.month - 1]} ${review.date.year}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(review.studentName[0], style: theme.textTheme.labelLarge),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.studentName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text(dateStr, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < review.rating ? Icons.star : Icons.star_border,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 11. Sticky Bottom Bar
// ---------------------------------------------------------------------------
class TutorStickyBottomBar extends StatelessWidget {
  final ThemeData theme;
  final double hourlyRate;
  final VoidCallback? onBook;
  final VoidCallback? onMessage;

  const TutorStickyBottomBar({super.key, required this.theme, required this.hourlyRate, this.onBook, this.onMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${hourlyRate.toStringAsFixed(0)}',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text('per lesson', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(width: 16),
          if (onMessage != null)
            IconButton(
              onPressed: onMessage,
              icon: const Icon(Icons.message_outlined),
            ),
          if (onMessage != null) const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onBook,
                child: const Text('Book trial lesson'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
