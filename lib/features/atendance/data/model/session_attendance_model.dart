import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';

class SessionAttendanceModel extends SessionAttendanceEntity {
  const SessionAttendanceModel({
    required super.attendanceId,
    required super.studentId,
    required super.name,
    super.picture,
    super.phoneNumber,
    super.parentPhoneNumber,
    required super.date,
    required super.time,
    super.sessionDate,
    super.sessionTime,
    required super.isLate,
  });

  factory SessionAttendanceModel.fromJson(Map<String, dynamic> json) {
    return SessionAttendanceModel(
      attendanceId: json['attendance_id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      picture: json['picture']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      parentPhoneNumber: json['parent_phone_number']?.toString(),
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      sessionDate: json['session_date']?.toString(),
      sessionTime: json['session_time']?.toString(),
      isLate: json['is_late'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'student_id': studentId,
      'name': name,
      'picture': picture,
      'phone_number': phoneNumber,
      'parent_phone_number': parentPhoneNumber,
      'date': date,
      'time': time,
      'session_date': sessionDate,
      'session_time': sessionTime,
      'is_late': isLate,
    };
  }
}
