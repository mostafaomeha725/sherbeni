import 'package:hive/hive.dart';

part 'pending_homework_grade_model.g.dart';

@HiveType(typeId: 7)
class PendingHomeworkGradeModel extends HiveObject {
  // Obsolete but kept for Hive backward compatibility
  @HiveField(0)
  final String? homeworkAttemptId;

  @HiveField(1)
  final String studentId;

  @HiveField(2)
  final String sessionId;

  // Obsolete but kept for Hive backward compatibility
  @HiveField(3)
  final String? homeworkTemplateId;

  @HiveField(4)
  final num grade;

  @HiveField(5)
  String? error;

  PendingHomeworkGradeModel({
    this.homeworkAttemptId,
    required this.studentId,
    required this.sessionId,
    this.homeworkTemplateId,
    required this.grade,
    this.error,
  });

  String get pendingKey => '${sessionId}_$studentId';
}
