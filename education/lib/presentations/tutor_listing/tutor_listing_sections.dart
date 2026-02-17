import 'package:centralized_library/centralized_library.dart';
import 'package:education/data/users/tutor_profile.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_bloc.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_event.dart';

class TutorListCard extends StatelessWidget {
  final TutorProfile tutor;
  final VoidCallback? onTap;
  final ThemeData theme;

  const TutorListCard({super.key, required this.tutor, this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    final text = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Avatar + Name/Badge/Rating/Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile image (rounded square)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: tutor.profileImageUrl != null
                        ? NetworkImageCard(
                            imageUrl: tutor.profileImageUrl!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(
                            width: 90,
                            height: 90,
                            child: Icon(Icons.person, size: 40),
                          ),
                  ),
                  const SizedBox(width: 14),
                  // Name, badge, rating, price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name row: name + verified + flag + favorite
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                tutor.name,
                                style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (tutor.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, size: 18),
                            ],
                            if (tutor.countryFlag != null) ...[
                              const SizedBox(width: 4),
                              Text(tutor.countryFlag!, style: const TextStyle(fontSize: 16)),
                            ],
                            const Spacer(),
                            const Icon(Icons.favorite_border, size: 22),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Professional badge
                        if (tutor.isProfessional)
                          Chip(
                            label: Text(
                              'Professional teacher',
                              style: text.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        const SizedBox(height: 6),
                        // Rating + reviews + price
                        Row(
                          children: [
                            if (tutor.rating > 0) ...[
                              const Icon(Icons.star, size: 16),
                              const SizedBox(width: 2),
                              Text(
                                tutor.rating.toStringAsFixed(1),
                                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              if (tutor.reviewCount > 0) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(${tutor.reviewCount} reviews)',
                                  style: text.bodySmall,
                                ),
                              ],
                            ],
                            const Spacer(),
                            Text(
                              '\$${tutor.hourlyRate.toStringAsFixed(0)}',
                              style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ' / ${tutor.lessonDurationMinutes} min',
                              style: text.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Section 2: Subject, active students/lessons, languages
              if (tutor.subject.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.menu_book_outlined, size: 16),
                    const SizedBox(width: 6),
                    Text('Teaches ', style: text.bodySmall),
                    Text(
                      tutor.subject,
                      style: text.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              Row(
                children: [
                  const Icon(Icons.people_outline, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${tutor.activeStudents} active students',
                    style: text.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${tutor.totalLessonsCompleted} lessons',
                    style: text.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (tutor.languagesSpoken.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.translate, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Speaks ${tutor.languagesSpoken.join(', ')}',
                        style: text.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              // Section 3: Bio preview
              if (tutor.bio.isNotEmpty) ...[
                Text.rich(
                  TextSpan(
                    children: [
                      if (tutor.title.isNotEmpty)
                        TextSpan(
                          text: '${tutor.title} — ',
                          style: text.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      TextSpan(
                        text: tutor.bio,
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Learn more',
                  style: text.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 14),
              // Bottom: Chat icon + Book trial lesson button
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => context.push('/chat/${tutor.userId}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      minimumSize: const Size(44, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.chat_bubble_outline, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Book trial lesson',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TutorFilterBar extends StatelessWidget {
  final ThemeData theme;

  const TutorFilterBar({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search tutors...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onChanged: (query) {
              context.read<TutorDiscoveryBloc>().add(FilterTutors(query: query));
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(label: 'All', onTap: () {
                  context.read<TutorDiscoveryBloc>().add(const FilterTutors());
                }),
                _FilterChip(label: 'Under \$30', onTap: () {
                  context.read<TutorDiscoveryBloc>().add(const FilterTutors(maxPrice: 30));
                }),
                _FilterChip(label: 'IELTS', onTap: () {
                  context.read<TutorDiscoveryBloc>().add(const FilterTutors(specialization: 'IELTS Preparation'));
                }),
                _FilterChip(label: 'Business English', onTap: () {
                  context.read<TutorDiscoveryBloc>().add(const FilterTutors(specialization: 'Business English'));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(label: Text(label), onPressed: onTap),
    );
  }
}
