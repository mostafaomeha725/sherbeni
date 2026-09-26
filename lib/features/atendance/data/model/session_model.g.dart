// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionModelAdapter extends TypeAdapter<SessionModel> {
  @override
  final int typeId = 1;

  @override
  SessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      courseId: fields[3] as String,
      courseTitle: fields[4] as String,
      startTime: fields[5] as String,
      endTime: fields[6] as String,
      status: fields[7] as String,
      hasHomework: fields[8] as bool,
      totalAttendance: fields[9] as int,
      attendedCount: fields[10] as int,
      lateCount: fields[11] as int,
      hasQuiz: fields[12] == null ? true : fields[12] as bool,
      quizName: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SessionModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.courseId)
      ..writeByte(4)
      ..write(obj.courseTitle)
      ..writeByte(5)
      ..write(obj.startTime)
      ..writeByte(6)
      ..write(obj.endTime)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.hasHomework)
      ..writeByte(9)
      ..write(obj.totalAttendance)
      ..writeByte(10)
      ..write(obj.attendedCount)
      ..writeByte(11)
      ..write(obj.lateCount)
      ..writeByte(12)
      ..write(obj.hasQuiz)
      ..writeByte(13)
      ..write(obj.quizName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
