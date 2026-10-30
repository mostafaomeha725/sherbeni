import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';

class ManualSearchStudentModel extends ManualSearchStudentEntity {
  const ManualSearchStudentModel({
    required super.studentId,
    required super.studentName,
    required super.studentCode,
    required super.educationalLevel,
    required super.status,
    required super.email,
    required super.phone,
    required super.parentPhone,
  });

  factory ManualSearchStudentModel.fromJson(Map<String, dynamic> json) {
    return ManualSearchStudentModel(
      studentId: (json['studentId'] as String?) ?? '',
      studentName: (json['studentName'] as String?) ?? '',
      studentCode: (json['studentQrCode'] as String?) ?? (json['studentCode'] as String?) ?? '',
      educationalLevel: (json['educationalLevel'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      parentPhone: (json['parentPhoneNumber'] as String?) ?? '',
    );
  }
}
