import 'package:equatable/equatable.dart';

class AttendanceEntity extends Equatable {
  final String uid;
  final String sessionId;
  final String attendance;
  final String homework;
  final String scanTime;

  const AttendanceEntity({
    required this.uid,
    required this.sessionId,
    required this.attendance,
    required this.homework,
    required this.scanTime,
  });

  @override
  List<Object?> get props => [uid, sessionId, attendance, homework, scanTime];
}
