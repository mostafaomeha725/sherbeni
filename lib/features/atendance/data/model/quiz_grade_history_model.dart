import 'package:hive/hive.dart';

part 'quiz_grade_history_model.g.dart';

@HiveType(typeId: 6)
class QuizGradeHistoryModel extends HiveObject {
  @HiveField(0)
  final String pendingKey; // sessionId_studentId

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final String sessionId;

  @HiveField(3)
  final String studentName;

  @HiveField(4)
  final String? quizName;

  @HiveField(5)
  final num grade;

  @HiveField(6)
  final num? maxScore;

  @HiveField(7)
  String syncStatus; // 'pending', 'success', 'failed'

  @HiveField(8)
  String? error;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  DateTime? syncedAt;

  @HiveField(11)
  String? sessionName;

  QuizGradeHistoryModel({
    required this.pendingKey,
    required this.studentId,
    required this.sessionId,
    required this.studentName,
    this.quizName,
    required this.grade,
    this.maxScore,
    required this.syncStatus,
    this.error,
    required this.createdAt,
    this.syncedAt,
    this.sessionName,
  });
}
