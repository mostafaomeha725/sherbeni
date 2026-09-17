import 'package:equatable/equatable.dart';

class QuizStudentEntity extends Equatable {
  final String studentId;
  final String name;
  final String studentCode;
  final String email;
  final String? phone;
  final String? picture;
  final String offlineStatus;
  final String? quizAttemptId;
  final String gradingStatus;
  final num? grade;
  final num maxScore;
  final num percentage;

  const QuizStudentEntity({
    required this.studentId,
    required this.name,
    required this.studentCode,
    required this.email,
    this.phone,
    this.picture,
    required this.offlineStatus,
    this.quizAttemptId,
    required this.gradingStatus,
    this.grade,
    required this.maxScore,
    required this.percentage,
  });

  @override
  List<Object?> get props => [
    studentId,
    name,
    studentCode,
    email,
    phone,
    picture,
    offlineStatus,
    quizAttemptId,
    gradingStatus,
    grade,
    maxScore,
    percentage,
  ];
}
