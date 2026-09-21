// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_class_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AcademicClassModelAdapter extends TypeAdapter<AcademicClassModel> {
  @override
  final int typeId = 4;

  @override
  AcademicClassModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AcademicClassModel(
      id: fields[0] as String,
      name: fields[1] as String,
      certificate: fields[2] as bool,
      educationSystem: fields[3] as String,
      sortOrder: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AcademicClassModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.certificate)
      ..writeByte(3)
      ..write(obj.educationSystem)
      ..writeByte(4)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicClassModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
