import 'package:equatable/equatable.dart';

class AcademicClassEntity extends Equatable {
  final String id;
  final String name;
  final bool certificate;
  final String educationSystem;
  final int sortOrder;

  const AcademicClassEntity({
    required this.id,
    required this.name,
    required this.certificate,
    required this.educationSystem,
    required this.sortOrder,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    certificate,
    educationSystem,
    sortOrder,
  ];
}
