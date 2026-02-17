import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/schedule/schedule_bloc.dart';
import 'package:education/blocs/schedule/schedule_event.dart';
import 'package:education/blocs/schedule/schedule_state.dart';
import 'package:education/presentations/schedule/schedule_sections.dart';

class MobileSchedulePage extends StatelessWidget {
  const MobileSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Schedule')),
      body: BlocConsumer<ScheduleBloc, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleLoaded && !state.hasUnsavedChanges && state.slots.isNotEmpty) {
            // Schedule saved feedback handled via save button
          }
        },
        builder: (context, state) {
          if (state is ScheduleLoading) return const Center(child: CircularProgressIndicator());
          if (state is ScheduleError) return Center(child: Text(state.message));
          if (state is ScheduleLoaded) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: WeeklyScheduleGrid(
                      slots: state.slots,
                      onToggleSlot: (slotId) => context.read<ScheduleBloc>().add(ToggleSlot(slotId)),
                      theme: theme,
                    ),
                  ),
                ),
                if (state.hasUnsavedChanges)
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => context.read<ScheduleBloc>().add(SaveSchedule()),
                        child: const Text('Save Schedule'),
                      ),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
