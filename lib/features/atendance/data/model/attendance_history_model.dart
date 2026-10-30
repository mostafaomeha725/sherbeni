import 'package:hive/hive.dart';

part 'attendance_history_model.g.dart';

@HiveType(typeId: 5)
class AttendanceHistoryModel extends HiveObject {
  @HiveField(0)
  final String pendingKey;

  @HiveField(1)
  final String uid;

  @HiveField(2)
  final String sessionId;

  @HiveField(3)
  final String studentName;

  @HiveField(4)
  final String scanTime;

  @HiveField(5)
  String syncStatus; // 'pending', 'success', 'failed'

  @HiveField(6)
  String? error;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  DateTime? syncedAt;

  @HiveField(9)
  final String? studentQrCode;

  @HiveField(10)
  final String? educationalLevel;

  @HiveField(11)
  final String? email;

  @HiveField(12)
  final String? phone;

  @HiveField(13)
  final String? parentPhoneNumber;

  @HiveField(14)
  String? sessionName;

  AttendanceHistoryModel({
    required this.pendingKey,
    required this.uid,
    required this.sessionId,
    required this.studentName,
    required this.scanTime,
    required this.syncStatus,
    this.error,
    required this.createdAt,
    this.syncedAt,
    this.studentQrCode,
    this.educationalLevel,
    this.email,
    this.phone,
    this.parentPhoneNumber,
    this.sessionName,
  });
}
