import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';

class SessionAttendanceModel extends SessionAttendanceEntity {
  const SessionAttendanceModel({
    required super.attendanceId,
    required super.studentId,
    required super.name,
    super.picture,
    super.phoneNumber,
    required super.date,
    required super.time,
    super.sessionDate,
    super.sessionTime,
    required super.isLate,
  });

  factory SessionAttendanceModel.fromJson(Map<String, dynamic> json) {
    return SessionAttendanceModel(
      attendanceId: json['attendance_id'] ?? '',
      studentId: json['student_id'] ?? '',
      name: json['name'] ?? '',
      picture: json['picture'],
      phoneNumber: json['phone_number'],
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      sessionDate: json['session_date'],
      sessionTime: json['session_time'],
      isLate: json['is_late'] ?? false,
    );
  }
}
