import 'package:centralized_library/centralized_library.dart';
import 'package:education/blocs/review/review_bloc.dart';
import 'package:education/blocs/review/review_event.dart';
import 'package:education/blocs/review/review_state.dart';
import 'package:education/data/reviews/review.dart';
import 'package:education/di/current_user_service.dart';
import 'package:education/di/service_locator.dart';
import 'package:education/presentations/reviews/review_sections.dart';

class ReviewSubmitPage extends StatefulWidget {
  final String bookingId;
  final String tutorId;

  const ReviewSubmitPage({super.key, required this.bookingId, required this.tutorId});

  @override
  State<ReviewSubmitPage> createState() => _ReviewSubmitPageState();
}

class _ReviewSubmitPageState extends State<ReviewSubmitPage> {
  final _commentController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted!')));
          context.pop();
        }
        if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Write a Review')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: ReviewForm(
                commentController: _commentController,
                rating: _rating,
                onRatingChanged: (r) => setState(() => _rating = r),
                theme: theme,
                onSubmit: () {
                  final currentUser = sl<CurrentUserService>();
                  context.read<ReviewBloc>().add(SubmitReview(Review(
                    reviewId: const Uuid().v4(),
                    tutorId: widget.tutorId,
                    studentId: currentUser.userId,
                    studentName: 'Current User',
                    rating: _rating,
                    comment: _commentController.text,
                    date: DateTime.now(),
                  )));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
