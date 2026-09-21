import 'package:hive/hive.dart';
import 'package:qrattendance/features/atendance/domain/entities/academic_class_entity.dart';

part 'academic_class_model.g.dart';

@HiveType(typeId: 4)
class AcademicClassModel extends HiveObject implements AcademicClassEntity {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String name;

  @override
  @HiveField(2)
  final bool certificate;

  @override
  @HiveField(3)
  final String educationSystem;

  @override
  @HiveField(4)
  final int sortOrder;

  AcademicClassModel({
    required this.id,
    required this.name,
    required this.certificate,
    required this.educationSystem,
    required this.sortOrder,
  });

  factory AcademicClassModel.fromJson(Map<String, dynamic> json) {
    return AcademicClassModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      certificate: json['certificate'] == true,
      educationSystem: json['educationSystem'] ?? '',
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder']
          : int.tryParse(json['sortOrder']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'certificate': certificate,
    'educationSystem': educationSystem,
    'sortOrder': sortOrder,
  };

  AcademicClassEntity toEntity() {
    return AcademicClassEntity(
      id: id,
      name: name,
      certificate: certificate,
      educationSystem: educationSystem,
      sortOrder: sortOrder,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    certificate,
    educationSystem,
    sortOrder,
  ];

  @override
  bool? get stringify => true;
}
