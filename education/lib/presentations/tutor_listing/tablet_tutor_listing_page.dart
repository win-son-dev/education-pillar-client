import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_bloc.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_state.dart';
import 'package:education/presentations/tutor_listing/tutor_listing_sections.dart';

class TabletTutorListingPage extends StatelessWidget {
  const TabletTutorListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Find a Tutor')),
      body: Column(
        children: [
          TutorFilterBar(theme: theme),
          Expanded(
            child: BlocBuilder<TutorDiscoveryBloc, TutorDiscoveryState>(
              builder: (context, state) {
                if (state is TutorDiscoveryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TutorDiscoveryError) {
                  return Center(child: Text(state.message));
                }
                if (state is TutorDiscoveryLoaded) {
                  if (state.tutors.isEmpty) {
                    return const Center(child: Text('No tutors found'));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: state.tutors.length,
                    itemBuilder: (context, index) {
                      final tutor = state.tutors[index];
                      return TutorListCard(
                        tutor: tutor,
                        theme: theme,
                        onTap: () => context.push('/tutor/${tutor.userId}'),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
