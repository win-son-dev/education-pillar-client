import 'package:centralized_library/centralized_library.dart';

class TutorProfile extends Equatable {
  final String userId;
  final String name;
  final String? profileImageUrl;
  final String? location;
  final List<String> languagesSpoken;
  final String title;
  final String bio;
  final String? videoIntroUrl;
  final List<String> specializations;
  final double hourlyRate;
  final int totalLessonsCompleted;
  final double rating;
  final int reviewCount;
  final int activeStudents;
  final String subject;
  final bool isVerified;
  final bool isProfessional;
  final String? countryFlag;
  final int lessonDurationMinutes;

  const TutorProfile({
    required this.userId,
    required this.name,
    this.profileImageUrl,
    this.location,
    this.languagesSpoken = const [],
    this.title = '',
    required this.bio,
    this.videoIntroUrl,
    required this.specializations,
    required this.hourlyRate,
    required this.totalLessonsCompleted,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.activeStudents = 0,
    this.subject = '',
    this.isVerified = false,
    this.isProfessional = false,
    this.countryFlag,
    this.lessonDurationMinutes = 50,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    profileImageUrl,
    location,
    languagesSpoken,
    title,
    bio,
    videoIntroUrl,
    specializations,
    hourlyRate,
    totalLessonsCompleted,
    rating,
    reviewCount,
    activeStudents,
    subject,
    isVerified,
    isProfessional,
    countryFlag,
    lessonDurationMinutes,
  ];

  TutorProfile copyWith({
    String? name,
    String? profileImageUrl,
    String? location,
    List<String>? languagesSpoken,
    String? title,
    String? bio,
    String? videoIntroUrl,
    List<String>? specializations,
    double? hourlyRate,
    int? totalLessonsCompleted,
    double? rating,
    int? reviewCount,
    int? activeStudents,
    String? subject,
    bool? isVerified,
    bool? isProfessional,
    String? countryFlag,
    int? lessonDurationMinutes,
  }) {
    return TutorProfile(
      userId: userId,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      location: location ?? this.location,
      languagesSpoken: languagesSpoken ?? this.languagesSpoken,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      videoIntroUrl: videoIntroUrl ?? this.videoIntroUrl,
      specializations: specializations ?? this.specializations,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      activeStudents: activeStudents ?? this.activeStudents,
      subject: subject ?? this.subject,
      isVerified: isVerified ?? this.isVerified,
      isProfessional: isProfessional ?? this.isProfessional,
      countryFlag: countryFlag ?? this.countryFlag,
      lessonDurationMinutes: lessonDurationMinutes ?? this.lessonDurationMinutes,
    );
  }
}
