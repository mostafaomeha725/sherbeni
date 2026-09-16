import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  final int id;
  final String name;

  const GroupEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class StudentEntity extends Equatable {
  final String id;
  final String studentQrCode;
  final String name;
  final String email;
  final String studentPhone;
  final String parentPhone;
  final String studentType;
  final bool isApproved;
  final GroupEntity? group;
  final bool? isAttended;

  const StudentEntity({
    required this.id,
    required this.studentQrCode,
    required this.name,
    required this.email,
    required this.studentPhone,
    required this.parentPhone,
    required this.studentType,
    required this.isApproved,
    this.group,
    this.isAttended,
  });

  @override
  List<Object?> get props => [
        id,
        studentQrCode,
        name,
        email,
        studentPhone,
        parentPhone,
        studentType,
        isApproved,
        group,
        isAttended,
      ];
}
