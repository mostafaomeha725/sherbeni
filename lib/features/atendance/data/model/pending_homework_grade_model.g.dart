// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_homework_grade_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingHomeworkGradeModelAdapter
    extends TypeAdapter<PendingHomeworkGradeModel> {
  @override
  final int typeId = 7;

  @override
  PendingHomeworkGradeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingHomeworkGradeModel(
      homeworkAttemptId: fields[0] as String?,
      studentId: fields[1] as String,
      sessionId: fields[2] as String,
      homeworkTemplateId: fields[3] as String?,
      grade: fields[4] as num,
      error: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingHomeworkGradeModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.homeworkAttemptId)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.sessionId)
      ..writeByte(3)
      ..write(obj.homeworkTemplateId)
      ..writeByte(4)
      ..write(obj.grade)
      ..writeByte(5)
      ..write(obj.error);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingHomeworkGradeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
