import 'package:equatable/equatable.dart';

class ManualSearchStudentEntity extends Equatable {
  final String studentId;
  final String studentName;
  final String studentCode;
  final String educationalLevel;
  final String status;
  final String email;
  final String phone;
  final String parentPhone;

  const ManualSearchStudentEntity({
    required this.studentId,
    required this.studentName,
    required this.studentCode,
    required this.educationalLevel,
    required this.status,
    required this.email,
    required this.phone,
    required this.parentPhone,
  });

  @override
  List<Object?> get props => [
    studentId,
    studentName,
    studentCode,
    educationalLevel,
    status,
    email,
    phone,
    parentPhone,
  ];
}
