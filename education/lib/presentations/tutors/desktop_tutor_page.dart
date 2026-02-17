import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/tutor_profile/tutor_profile_bloc.dart';
import 'package:education/blocs/tutor_profile/tutor_profile_state.dart';
import 'package:education/data/messages/message_repository.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/di/service_locator.dart';
import 'package:education/presentations/tutors/tutor_sections.dart';

class DesktopTutorPage extends StatelessWidget {
  const DesktopTutorPage({super.key});

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
          appBar: AppBar(
            title: Text(tutor.name),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  final currentUser = sl<CurrentUserService>();
                  final repo = sl<MessageRepository>();
                  final room = await repo.findOrCreateRoom(currentUser.userId, tutor.userId);
                  if (context.mounted) context.push('/chat/${room.roomId}');
                },
                icon: const Icon(Icons.message_outlined),
                label: const Text('Message'),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 340,
                    child: ListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      children: [
                        TutorProfileHeader(tutor: tutor, reviews: reviews, theme: theme),
                        TutorQuickStatsRow(tutor: tutor, reviews: reviews, theme: theme),
                        TutorBookTrialCta(
                          theme: theme,
                          hourlyRate: tutor.hourlyRate,
                          onBook: () => context.push('/book/${tutor.userId}'),
                        ),
                        TutorSchedulePreview(slots: scheduleSlots, theme: theme),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      children: [
                        TutorVideoIntroCard(tutor: tutor, theme: theme),
                        TutorAboutMeSection(bio: tutor.bio, theme: theme),
                        TutorSpecializationsSection(specializations: tutor.specializations, theme: theme),
                        TutorCertificationsSection(certifications: certifications, theme: theme),
                        TutorLanguagesSection(languages: tutor.languagesSpoken, theme: theme),
                        TutorReviewsSection(reviews: reviews, theme: theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
