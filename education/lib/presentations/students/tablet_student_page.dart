import 'package:flutter/material.dart';
import 'package:education/data/users/student_profile.dart';
import 'package:education/data/bookings/booking.dart';
import 'package:education/presentations/students/student_sections.dart';

class TabletStudentPage extends StatelessWidget {
  final StudentProfile student;
  final List<Booking> bookings;

  const TabletStudentPage({super.key, required this.student, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              children: [
                StudentProfileHeader(student: student, theme: theme),
                StudentLanguagesSection(languages: student.languagesSpoken, theme: theme),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ListView(
              children: [
                LearningGoals(goals: student.learningGoals, theme: theme),
                UpcomingBookingsSection(bookings: bookings, theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
