import 'package:equatable/equatable.dart';

class SessionAttendanceEntity extends Equatable {
  final String attendanceId;
  final String studentId;
  final String name;
  final String? picture;
  final String? phoneNumber;
  final String date;
  final String time;
  final String? sessionDate;
  final String? sessionTime;
  final bool isLate;

  const SessionAttendanceEntity({
    required this.attendanceId,
    required this.studentId,
    required this.name,
    this.picture,
    this.phoneNumber,
    required this.date,
    required this.time,
    this.sessionDate,
    this.sessionTime,
    required this.isLate,
  });

  @override
  List<Object?> get props => [
        attendanceId,
        studentId,
        name,
        picture,
        phoneNumber,
        date,
        time,
        sessionDate,
        sessionTime,
        isLate,
      ];
}
