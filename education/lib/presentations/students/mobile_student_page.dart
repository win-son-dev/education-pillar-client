import 'package:flutter/material.dart';
import 'package:education/data/users/student_profile.dart';
import 'package:education/data/bookings/booking.dart';
import 'package:education/presentations/students/student_sections.dart';

class MobileStudentPage extends StatelessWidget {
  final StudentProfile student;
  final List<Booking> bookings;

  const MobileStudentPage({super.key, required this.student, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: ListView(
        children: [
          StudentProfileHeader(student: student, theme: theme),
          LearningGoals(goals: student.learningGoals, theme: theme),
          StudentLanguagesSection(languages: student.languagesSpoken, theme: theme),
          UpcomingBookingsSection(bookings: bookings, theme: theme),
        ],
      ),
    );
  }
}
