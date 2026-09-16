import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String courseTitle;
  final String startTime;
  final String endTime;
  final String status;
  final bool hasHomework;
  final int totalAttendance;
  final int attendedCount;
  final int lateCount;
  final int? quizMaxGrade;

  // TODO: Remove this temporary default once the backend provides the real max grade
  static const int temporaryDefaultQuizMaxGrade = 20;

  int get effectiveQuizMaxGrade => quizMaxGrade ?? temporaryDefaultQuizMaxGrade;
  const SessionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.courseTitle,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.hasHomework,
    required this.totalAttendance,
    required this.attendedCount,
    required this.lateCount,
    this.quizMaxGrade,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    courseId,
    courseTitle,
    startTime,
    endTime,
    status,
    hasHomework,
    totalAttendance,
    attendedCount,
    lateCount,
    quizMaxGrade,
  ];
}
