enum UserRole { student, tutor }

class CurrentUserService {
  UserRole currentRole;
  String userId;

  CurrentUserService({
    this.currentRole = UserRole.student,
    this.userId = 'student-1',
  });

  bool get isStudent => currentRole == UserRole.student;
  bool get isTutor => currentRole == UserRole.tutor;

  void switchToStudent(String studentId) {
    currentRole = UserRole.student;
    userId = studentId;
  }

  void switchToTutor(String tutorId) {
    currentRole = UserRole.tutor;
    userId = tutorId;
  }
}
