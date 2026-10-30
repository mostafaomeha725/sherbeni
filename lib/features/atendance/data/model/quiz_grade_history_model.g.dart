// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_grade_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizGradeHistoryModelAdapter extends TypeAdapter<QuizGradeHistoryModel> {
  @override
  final int typeId = 6;

  @override
  QuizGradeHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizGradeHistoryModel(
      pendingKey: fields[0] as String,
      studentId: fields[1] as String,
      sessionId: fields[2] as String,
      studentName: fields[3] as String,
      quizName: fields[4] as String?,
      grade: fields[5] as num,
      maxScore: fields[6] as num?,
      syncStatus: fields[7] as String,
      error: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      syncedAt: fields[10] as DateTime?,
      sessionName: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizGradeHistoryModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.pendingKey)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.sessionId)
      ..writeByte(3)
      ..write(obj.studentName)
      ..writeByte(4)
      ..write(obj.quizName)
      ..writeByte(5)
      ..write(obj.grade)
      ..writeByte(6)
      ..write(obj.maxScore)
      ..writeByte(7)
      ..write(obj.syncStatus)
      ..writeByte(8)
      ..write(obj.error)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.syncedAt)
      ..writeByte(11)
      ..write(obj.sessionName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizGradeHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
