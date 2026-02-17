import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/tutor_profile/tutor_profile_bloc.dart';
import 'package:education/blocs/tutor_profile/tutor_profile_state.dart';
import 'package:education/data/messages/message_repository.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/di/service_locator.dart';
import 'package:education/presentations/tutors/tutor_sections.dart';

class TabletTutorPage extends StatelessWidget {
  const TabletTutorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<TutorProfileBloc, TutorProfileState>(
      builder: (context, state) {
        if (state is TutorProfileLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (state is TutorProfileError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is! TutorProfileLoaded) {
          return const Scaffold(body: SizedBox.shrink());
        }

        final tutor = state.tutor;
        final certifications = state.certifications;
        final reviews = state.reviews;
        final scheduleSlots = state.slots;

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(pinned: true, title: Text(tutor.name)),
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                TutorProfileHeader(tutor: tutor, reviews: reviews, theme: theme),
                                TutorVideoIntroCard(tutor: tutor, theme: theme),
                                TutorQuickStatsRow(tutor: tutor, reviews: reviews, theme: theme),
                                TutorBookTrialCta(
                                  theme: theme,
                                  hourlyRate: tutor.hourlyRate,
                                  onBook: () => context.push('/book/${tutor.userId}'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                TutorAboutMeSection(bio: tutor.bio, theme: theme),
                                TutorSpecializationsSection(specializations: tutor.specializations, theme: theme),
                                TutorCertificationsSection(certifications: certifications, theme: theme),
                                TutorLanguagesSection(languages: tutor.languagesSpoken, theme: theme),
                                TutorSchedulePreview(slots: scheduleSlots, theme: theme),
                                TutorReviewsSection(reviews: reviews, theme: theme),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: TutorStickyBottomBar(
                  theme: theme,
                  hourlyRate: tutor.hourlyRate,
                  onBook: () => context.push('/book/${tutor.userId}'),
                  onMessage: () async {
                    final currentUser = sl<CurrentUserService>();
                    final repo = sl<MessageRepository>();
                    final room = await repo.findOrCreateRoom(currentUser.userId, tutor.userId);
                    if (context.mounted) context.push('/chat/${room.roomId}');
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
