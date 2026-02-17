import 'package:flutter/material.dart';

class StarRatingInput extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;

  const StarRatingInput({super.key, required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return IconButton(
          onPressed: () => onRatingChanged(i + 1),
          icon: Icon(
            i < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 36,
          ),
        );
      }),
    );
  }
}

class ReviewForm extends StatelessWidget {
  final TextEditingController commentController;
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;
  final ThemeData theme;

  const ReviewForm({
    super.key,
    required this.commentController,
    required this.rating,
    required this.onRatingChanged,
    required this.onSubmit,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate your experience', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Center(child: StarRatingInput(rating: rating, onRatingChanged: onRatingChanged)),
          const SizedBox(height: 24),
          Text('Leave a comment', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: rating > 0 ? onSubmit : null,
              child: const Text('Submit Review'),
            ),
          ),
        ],
      ),
    );
  }
}
