import 'package:hive/hive.dart';

part 'student_model.g.dart';

@HiveType(typeId: 2)
class StudentModel extends HiveObject {
  @HiveField(0)
  final String id; // Maps to API's `uid`
  
  @HiveField(1)
  final String name;

  StudentModel({required this.id, required this.name});

  factory StudentModel.fromJson(Map<String, dynamic> json) =>
      StudentModel(id: json['id'].toString(), name: json['name']);
}
