import 'package:education/data/certifications/certification.dart';
import 'package:education/data/schedules/schedule_slot.dart';
import 'package:education/data/users/tutor_profile.dart';

abstract class TutorRepository {
  Future<List<TutorProfile>> getTutors();
  Future<TutorProfile?> getTutorById(String tutorId);
  Future<List<Certification>> getCertifications(String tutorId);
  Future<List<ScheduleSlot>> getAvailableSlots(String tutorId);
  Future<void> updateSlot(ScheduleSlot slot);
}
