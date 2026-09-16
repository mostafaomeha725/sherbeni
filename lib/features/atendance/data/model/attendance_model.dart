import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 0)
class AttendanceModel extends HiveObject {
  @HiveField(0)
  final String uid; // student id

  @HiveField(1)
  final String sessionId;

  @HiveField(4)
  final String scanTime;

  AttendanceModel({
    required this.uid,
    required this.sessionId,
    required this.scanTime,
  });

  /// Convert to API-compatible JSON
  Map<String, dynamic> toJson() {
    return {'uid': uid};
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      uid: json['uid'] ?? '',
      sessionId: json['session_id'] ?? '',
      scanTime: json['scan_time'] ?? '',
    );
  }

  @override
  String toString() {
    return 'AttendanceModel(uid: $uid, sessionId: $sessionId, scanTime: $scanTime)';
  }
}
