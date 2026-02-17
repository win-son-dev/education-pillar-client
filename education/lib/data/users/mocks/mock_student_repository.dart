import 'package:education/data/users/student_profile.dart';
import 'package:education/data/users/student_repository.dart';

class MockStudentRepository implements StudentRepository {
  final List<StudentProfile> _students = [
    const StudentProfile(
      userId: 'student-1',
      name: 'Alex Rivera',
      profileImageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
      location: 'New York, USA',
      languagesSpoken: ['English', 'Spanish'],
      learningGoals: ['Pass IELTS with band 7+', 'Improve business English', 'Prepare for job interviews'],
      bio: 'Software developer looking to improve English for career growth.',
    ),
    const StudentProfile(
      userId: 'student-2',
      name: 'Yuki Tanaka',
      profileImageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
      location: 'Tokyo, Japan',
      languagesSpoken: ['Japanese', 'English'],
      learningGoals: ['Conversational English fluency', 'Academic writing'],
      bio: 'University student preparing for study abroad program.',
    ),
  ];

  static const _currentStudentId = 'student-1';

  @override
  Future<StudentProfile?> getStudentById(String studentId) async {
    try {
      return _students.firstWhere((s) => s.userId == studentId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<StudentProfile> getCurrentStudent() async {
    return _students.firstWhere((s) => s.userId == _currentStudentId);
  }

  @override
  Future<void> updateStudentProfile(StudentProfile profile) async {
    final index = _students.indexWhere((s) => s.userId == profile.userId);
    if (index != -1) {
      _students[index] = profile;
    }
  }
}
