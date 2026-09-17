import 'package:qrattendance/features/atendance/domain/entities/quiz_student_entity.dart';

class QuizStudentModel extends QuizStudentEntity {
  const QuizStudentModel({
    required super.studentId,
    required super.name,
    required super.studentCode,
    required super.email,
    super.phone,
    super.picture,
    required super.offlineStatus,
    super.quizAttemptId,
    required super.gradingStatus,
    super.grade,
    required super.maxScore,
    required super.percentage,
  });

  factory QuizStudentModel.fromJson(Map<String, dynamic> json) {
    return QuizStudentModel(
      studentId: json['student_id'] ?? '',
      name: json['name'] ?? '',
      studentCode: json['studentCode']?.toString() ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      picture: json['picture'],
      offlineStatus: json['offline_status'] ?? 'unknown',
      quizAttemptId: json['quiz_attempt_id'],
      gradingStatus: json['grading_status'] ?? 'unknown',
      grade: json['grade'] as num?,
      maxScore: json['maxScore'] as num? ?? 0,
      percentage: json['percentage'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'studentCode': studentCode,
      'email': email,
      'phone': phone,
      'picture': picture,
      'offline_status': offlineStatus,
      'quiz_attempt_id': quizAttemptId,
      'grading_status': gradingStatus,
      'grade': grade,
      'maxScore': maxScore,
      'percentage': percentage,
    };
  }
}
