import 'package:centralized_library/centralized_library.dart';

class StudentProfile extends Equatable {
  final String userId;
  final String name;
  final String? profileImageUrl;
  final String? location;
  final List<String> languagesSpoken;
  final List<String> learningGoals;
  final String bio;

  const StudentProfile({
    required this.userId,
    required this.name,
    this.profileImageUrl,
    this.location,
    this.languagesSpoken = const [],
    this.learningGoals = const [],
    this.bio = '',
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    profileImageUrl,
    location,
    languagesSpoken,
    learningGoals,
    bio,
  ];

  StudentProfile copyWith({
    String? name,
    String? profileImageUrl,
    String? location,
    List<String>? languagesSpoken,
    List<String>? learningGoals,
    String? bio,
  }) {
    return StudentProfile(
      userId: userId,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      location: location ?? this.location,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      learningGoals: learningGoals ?? this.learningGoals,
      bio: bio ?? this.bio,
    );
  }
}
