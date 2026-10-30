import 'package:hive/hive.dart';

part 'student_model.g.dart';

@HiveType(typeId: 2)
class StudentModel extends HiveObject {
  @HiveField(0)
  final String id; // Maps to API's `uid`

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? studentQrCode;

  @HiveField(3)
  final String? studentType;

  @HiveField(4)
  final String? email;

  @HiveField(5)
  final String? studentPhone;

  @HiveField(6)
  final String? parentPhone;

  StudentModel({
    required this.id,
    required this.name,
    this.studentQrCode,
    this.studentType,
    this.email,
    this.studentPhone,
    this.parentPhone,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'].toString(),
    name: json['name']?.toString() ?? '',
    studentQrCode: json['student_qr_code']?.toString(),
    studentType: json['educational_level']?.toString(),
    email: json['email']?.toString(),
    studentPhone: json['phone']?.toString(),
    parentPhone: json['parent_phone_number']?.toString(),
  );
}
