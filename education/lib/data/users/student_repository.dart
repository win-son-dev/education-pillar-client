import 'package:education/data/users/student_profile.dart';

abstract class StudentRepository {
  Future<StudentProfile?> getStudentById(String studentId);
  Future<StudentProfile> getCurrentStudent();
  Future<void> updateStudentProfile(StudentProfile profile);
}
