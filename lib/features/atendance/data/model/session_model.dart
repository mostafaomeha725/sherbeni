import 'package:hive/hive.dart';
import '../../domain/entities/session_entity.dart';

part 'session_model.g.dart';

@HiveType(typeId: 1)
class SessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String courseId;

  @HiveField(4)
  final String courseTitle;

  @HiveField(5)
  final String startTime;

  @HiveField(6)
  final String endTime;

  @HiveField(7)
  final String status;

  @HiveField(8)
  final bool hasHomework;

  @HiveField(9)
  final int totalAttendance;

  @HiveField(10)
  final int attendedCount;

  @HiveField(11)
  final int lateCount;

  @HiveField(12, defaultValue: true)
  final bool hasQuiz;

  SessionModel({
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
    required this.hasQuiz,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    String teacherName = '';
    if (json['teachers'] != null &&
        json['teachers'] is List &&
        (json['teachers'] as List).isNotEmpty) {
      teacherName = (json['teachers'] as List)
          .map((t) => t['name']?.toString() ?? '')
          .join(' و ');
    }

    return SessionModel(
      id: json['id']?.toString() ?? '',
      title:
          json['educational_level_name'] ??
          json['center_name'] ??
          json['title'] ??
          '',
      description: teacherName.isNotEmpty
          ? teacherName
          : (json['description'] ?? ''),
      courseId:
          json['course']?['id']?.toString() ??
          json['educational_level_id']?.toString() ??
          json['center_id']?.toString() ??
          '',
      courseTitle: json['name'] ?? json['course']?['title'] ?? '',
      startTime: json['start_time'] ?? json['date'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? '',
      hasHomework: json['has_homework'] ?? false,
      totalAttendance: json['total_attendance'] ?? 0,
      attendedCount: json['attended_count'] ?? 0,
      lateCount: json['late_count'] ?? 0,
      hasQuiz: json['hasQuiz'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "course_id": courseId,
    "course_title": courseTitle,
    "start_time": startTime,
    "end_time": endTime,
    "status": status,
    "has_homework": hasHomework,
    "total_attendance": totalAttendance,
    "attended_count": attendedCount,
    "late_count": lateCount,
    "hasQuiz": hasQuiz,
  };

  SessionEntity toEntity() {
    return SessionEntity(
      id: id,
      title: title,
      description: description,
      courseId: courseId,
      courseTitle: courseTitle,
      startTime: startTime,
      endTime: endTime,
      status: status,
      hasHomework: hasHomework,
      totalAttendance: totalAttendance,
      attendedCount: attendedCount,
      lateCount: lateCount,
      hasQuiz: hasQuiz,
    );
  }
}
