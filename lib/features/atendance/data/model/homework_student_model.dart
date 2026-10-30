import 'package:qrattendance/features/atendance/domain/entities/homework_student_entity.dart';

class HomeworkStudentModel extends HomeworkStudentEntity {
  const HomeworkStudentModel({
    required super.studentId,
    required super.name,
    required super.studentCode,
    required super.email,
    super.phoneNumber,
    super.picture,
    required super.offlineStatus,
    super.homeworkAttemptId,
    required super.gradingStatus,
    super.grade,
    super.maxScore,
    super.percentage,
    super.approvedBy,
    super.approvedAt,
  });

  factory HomeworkStudentModel.fromJson(Map<String, dynamic> json) {
    return HomeworkStudentModel(
      studentId: json['student_id'] ?? '',
      name: json['name'] ?? '',
      studentCode:
          (json['student_code'] ?? json['studentCode'])?.toString() ?? '',
      email: json['email'] ?? '',
      phoneNumber: (json['phone_number'] ?? json['phone'])?.toString(),
      picture: json['picture'],
      offlineStatus: json['offline_status'] ?? 'unknown',
      homeworkAttemptId: json['homework_attempt_id'],
      gradingStatus: json['grading_status'] ?? 'unknown',
      grade: json['grade'] as num?,
      maxScore: json['maxScore'] as num?,
      percentage: json['percentage'] as num?,
      approvedBy: json['approved_by'] as Map<String, dynamic>?,
      approvedAt: json['approved_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'student_code': studentCode,
      'email': email,
      'phone_number': phoneNumber,
      'picture': picture,
      'offline_status': offlineStatus,
      'homework_attempt_id': homeworkAttemptId,
      'grading_status': gradingStatus,
      'grade': grade,
      'maxScore': maxScore,
      'percentage': percentage,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
    };
  }
}
