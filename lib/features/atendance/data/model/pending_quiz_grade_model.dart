import 'package:hive/hive.dart';

part 'pending_quiz_grade_model.g.dart';

@HiveType(typeId: 3)
class PendingQuizGradeModel extends HiveObject {
  // Obsolete but kept for Hive backward compatibility
  @HiveField(0)
  final String? quizAttemptId;

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final String sessionId;

  // Obsolete but kept for Hive backward compatibility
  @HiveField(3)
  final String? quizTemplateId;

  @HiveField(4)
  final num grade;

  @HiveField(5)
  String? error;

  PendingQuizGradeModel({
    this.quizAttemptId,
    required this.studentId,
    required this.sessionId,
    this.quizTemplateId,
    required this.grade,
    this.error,
  });

  String get pendingKey => '${sessionId}_$studentId';
}
