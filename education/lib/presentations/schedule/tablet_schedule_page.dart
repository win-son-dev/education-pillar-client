import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/schedule/schedule_bloc.dart';
import 'package:education/blocs/schedule/schedule_event.dart';
import 'package:education/blocs/schedule/schedule_state.dart';
import 'package:education/presentations/schedule/schedule_sections.dart';

class TabletSchedulePage extends StatelessWidget {
  const TabletSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        actions: [
          BlocBuilder<ScheduleBloc, ScheduleState>(
            builder: (context, state) {
              if (state is ScheduleLoaded && state.hasUnsavedChanges) {
                return TextButton(
                  onPressed: () => context.read<ScheduleBloc>().add(SaveSchedule()),
                  child: const Text('Save'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) return const Center(child: CircularProgressIndicator());
          if (state is ScheduleError) return Center(child: Text(state.message));
          if (state is ScheduleLoaded) {
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: WeeklyScheduleGrid(
                    slots: state.slots,
                    onToggleSlot: (slotId) => context.read<ScheduleBloc>().add(ToggleSlot(slotId)),
                    theme: theme,
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
