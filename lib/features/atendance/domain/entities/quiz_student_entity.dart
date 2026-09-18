import 'package:equatable/equatable.dart';

class QuizStudentEntity extends Equatable {
  final String studentId;
  final String name;
  final String studentCode;
  final String email;
  final String? phoneNumber;
  final String? picture;
  final String offlineStatus;
  final String? quizAttemptId;
  final String gradingStatus;
  final num? grade;
  final num? maxScore;
  final num? percentage;
  final Map<String, dynamic>? approvedBy;
  final String? approvedAt;

  const QuizStudentEntity({
    required this.studentId,
    required this.name,
    required this.studentCode,
    required this.email,
    this.phoneNumber,
    this.picture,
    required this.offlineStatus,
    this.quizAttemptId,
    required this.gradingStatus,
    this.grade,
    this.maxScore,
    this.percentage,
    this.approvedBy,
    this.approvedAt,
  });

  @override
  List<Object?> get props => [
    studentId,
    name,
    studentCode,
    email,
    phoneNumber,
    picture,
    offlineStatus,
    quizAttemptId,
    gradingStatus,
    grade,
    maxScore,
    percentage,
    approvedBy,
    approvedAt,
  ];
}
