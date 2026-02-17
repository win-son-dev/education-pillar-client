import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_bloc.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_event.dart';
import 'package:education/blocs/tutor_discovery/tutor_discovery_state.dart';
import 'package:education/presentations/tutor_listing/tutor_listing_sections.dart';

class DesktopTutorListingPage extends StatelessWidget {
  const DesktopTutorListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Find a Tutor')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 280,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Filters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search tutors...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (query) {
                        context.read<TutorDiscoveryBloc>().add(FilterTutors(query: query));
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Price Range', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(label: const Text('All'), onPressed: () {
                          context.read<TutorDiscoveryBloc>().add(const FilterTutors());
                        }),
                        ActionChip(label: const Text('Under \$30'), onPressed: () {
                          context.read<TutorDiscoveryBloc>().add(const FilterTutors(maxPrice: 30));
                        }),
                        ActionChip(label: const Text('Under \$40'), onPressed: () {
                          context.read<TutorDiscoveryBloc>().add(const FilterTutors(maxPrice: 40));
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Specialization', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(label: const Text('IELTS'), onPressed: () {
                          context.read<TutorDiscoveryBloc>().add(const FilterTutors(specialization: 'IELTS Preparation'));
                        }),
                        ActionChip(label: const Text('Business English'), onPressed: () {
                          context.read<TutorDiscoveryBloc>().add(const FilterTutors(specialization: 'Business English'));
                        }),
                        ActionChip(label: const Text('Python'), onPressed: () {
                          context.read<TutorDiscoveryBloc>().add(const FilterTutors(specialization: 'Python'));
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
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
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
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
        ),
      ),
    );
  }
}
