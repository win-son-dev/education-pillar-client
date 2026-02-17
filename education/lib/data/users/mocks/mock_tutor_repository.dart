import 'package:education/data/certifications/certification.dart';
import 'package:education/data/schedules/schedule_slot.dart';
import 'package:education/data/users/tutor_profile.dart';
import 'package:education/data/users/tutor_repository.dart';

class MockTutorRepository implements TutorRepository {
  final List<TutorProfile> _tutors = [
    const TutorProfile(
      userId: 'tutor-1',
      name: 'Sarah Johnson',
      profileImageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
      location: 'London, United Kingdom',
      languagesSpoken: ['English', 'Spanish', 'French'],
      title: 'Certified IELTS & Business English Specialist',
      bio: 'Experienced ESL teacher with 25 years of IELTS expertise. '
          'I specialize in helping students achieve their target band scores '
          'through structured lesson plans and real exam practice. '
          'My lessons are interactive and tailored to each student\'s needs.',
      videoIntroUrl: 'https://example.com/intro.mp4',
      specializations: ['IELTS Preparation', 'Business English', 'Conversational English', 'Academic Writing', 'Interview Prep'],
      hourlyRate: 26.0,
      totalLessonsCompleted: 1199,
      rating: 4.9,
      reviewCount: 287,
      activeStudents: 34,
      subject: 'English',
      isVerified: true,
      isProfessional: true,
      countryFlag: '🇬🇧',
      lessonDurationMinutes: 50,
    ),
    const TutorProfile(
      userId: 'tutor-2',
      name: 'Michael Chen',
      profileImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      location: 'Toronto, Canada',
      languagesSpoken: ['English', 'Mandarin'],
      title: 'Math & Science Tutor',
      bio: 'PhD in Mathematics with 10 years of tutoring experience. '
          'I make complex concepts simple and fun.',
      specializations: ['Calculus', 'Linear Algebra', 'Physics', 'Statistics'],
      hourlyRate: 35.0,
      totalLessonsCompleted: 842,
      rating: 4.8,
      reviewCount: 156,
      activeStudents: 21,
      subject: 'Mathematics',
      isVerified: true,
      isProfessional: true,
      countryFlag: '🇨🇦',
      lessonDurationMinutes: 60,
    ),
    const TutorProfile(
      userId: 'tutor-3',
      name: 'Elena Petrova',
      profileImageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
      location: 'Berlin, Germany',
      languagesSpoken: ['English', 'Russian', 'German'],
      title: 'Piano & Music Theory Instructor',
      bio: 'Concert pianist turned educator. I teach piano from beginner to advanced levels '
          'with a focus on classical and jazz repertoire.',
      specializations: ['Piano', 'Music Theory', 'Sight Reading', 'Jazz Improvisation'],
      hourlyRate: 40.0,
      totalLessonsCompleted: 567,
      rating: 5.0,
      reviewCount: 98,
      activeStudents: 12,
      subject: 'Music',
      isVerified: true,
      isProfessional: false,
      countryFlag: '🇩🇪',
      lessonDurationMinutes: 50,
    ),
    const TutorProfile(
      userId: 'tutor-4',
      name: 'Priya Sharma',
      profileImageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      location: 'Mumbai, India',
      languagesSpoken: ['English', 'Hindi', 'Marathi'],
      title: 'Software Engineering & Python Expert',
      bio: 'Senior software engineer at a top tech company. '
          'I help students learn programming from scratch or prepare for coding interviews.',
      specializations: ['Python', 'Data Structures', 'Algorithms', 'System Design'],
      hourlyRate: 30.0,
      totalLessonsCompleted: 395,
      rating: 4.7,
      reviewCount: 73,
      activeStudents: 18,
      subject: 'Programming',
      isVerified: true,
      isProfessional: true,
      countryFlag: '🇮🇳',
      lessonDurationMinutes: 55,
    ),
    const TutorProfile(
      userId: 'tutor-5',
      name: 'James Wilson',
      profileImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      location: 'Sydney, Australia',
      languagesSpoken: ['English'],
      title: 'TOEFL & Academic English Specialist',
      bio: 'Former university lecturer specializing in academic English '
          'and standardized test preparation.',
      specializations: ['TOEFL Preparation', 'Academic Writing', 'Research Skills', 'Presentation Skills'],
      hourlyRate: 28.0,
      totalLessonsCompleted: 721,
      rating: 4.6,
      reviewCount: 132,
      activeStudents: 25,
      subject: 'English',
      isVerified: false,
      isProfessional: true,
      countryFlag: '🇦🇺',
      lessonDurationMinutes: 50,
    ),
  ];

  final Map<String, List<Certification>> _certifications = {
    'tutor-1': [
      Certification(certificationId: 'cert-1', name: 'TEFL Level 5', issuingOrganization: 'TEFL Institute', dateObtained: DateTime(2015, 6), isVerified: true),
      Certification(certificationId: 'cert-2', name: 'TESOL Certified', issuingOrganization: 'International TESOL Association', dateObtained: DateTime(2016, 3), isVerified: true),
      Certification(certificationId: 'cert-3', name: 'Cambridge CELTA', issuingOrganization: 'Cambridge University Press', dateObtained: DateTime(2014, 9), isVerified: true),
      Certification(certificationId: 'cert-4', name: 'MA Applied Linguistics', issuingOrganization: 'University of London', dateObtained: DateTime(2012, 7), isVerified: false),
    ],
    'tutor-2': [
      Certification(certificationId: 'cert-5', name: 'PhD Mathematics', issuingOrganization: 'MIT', dateObtained: DateTime(2013, 5), isVerified: true),
    ],
    'tutor-3': [
      Certification(certificationId: 'cert-6', name: 'ABRSM Grade 8 Piano', issuingOrganization: 'ABRSM', dateObtained: DateTime(2010, 11), isVerified: true),
    ],
    'tutor-4': [
      Certification(certificationId: 'cert-7', name: 'AWS Certified Developer', issuingOrganization: 'Amazon', dateObtained: DateTime(2022, 1), isVerified: true),
    ],
    'tutor-5': [
      Certification(certificationId: 'cert-8', name: 'DELTA Module 1', issuingOrganization: 'Cambridge', dateObtained: DateTime(2018, 6), isVerified: true),
    ],
  };

  late final List<ScheduleSlot> _slots;

  MockTutorRepository() {
    _slots = _generateSlots();
  }

  List<ScheduleSlot> _generateSlots() {
    final slots = <ScheduleSlot>[];
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final timeSlots = ['9 AM', '12 PM', '3 PM', '6 PM'];
    final endTimes = ['10 AM', '1 PM', '4 PM', '7 PM'];

    for (final tutor in _tutors) {
      for (var i = 0; i < timeSlots.length; i++) {
        for (var j = 0; j < 7; j++) {
          // Pseudo-random availability based on tutor+slot indices
          if ((i + j + tutor.userId.hashCode) % 3 != 0) {
            slots.add(ScheduleSlot(
              slotId: 'slot-${tutor.userId}-$i-$j',
              tutorId: tutor.userId,
              date: monday.add(Duration(days: j)),
              startTime: timeSlots[i],
              endTime: endTimes[i],
            ));
          }
        }
      }
    }
    return slots;
  }

  @override
  Future<List<TutorProfile>> getTutors() async {
    return List.unmodifiable(_tutors);
  }

  @override
  Future<TutorProfile?> getTutorById(String tutorId) async {
    try {
      return _tutors.firstWhere((t) => t.userId == tutorId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Certification>> getCertifications(String tutorId) async {
    return _certifications[tutorId] ?? [];
  }

  @override
  Future<List<ScheduleSlot>> getAvailableSlots(String tutorId) async {
    return _slots.where((s) => s.tutorId == tutorId && !s.isBooked).toList();
  }

  @override
  Future<void> updateSlot(ScheduleSlot slot) async {
    final index = _slots.indexWhere((s) => s.slotId == slot.slotId);
    if (index != -1) {
      _slots[index] = slot;
    }
  }
}
