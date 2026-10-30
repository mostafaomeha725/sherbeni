// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceHistoryModelAdapter
    extends TypeAdapter<AttendanceHistoryModel> {
  @override
  final int typeId = 5;

  @override
  AttendanceHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceHistoryModel(
      pendingKey: fields[0] as String,
      uid: fields[1] as String,
      sessionId: fields[2] as String,
      studentName: fields[3] as String,
      scanTime: fields[4] as String,
      syncStatus: fields[5] as String,
      error: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      syncedAt: fields[8] as DateTime?,
      studentQrCode: fields[9] as String?,
      educationalLevel: fields[10] as String?,
      email: fields[11] as String?,
      phone: fields[12] as String?,
      parentPhoneNumber: fields[13] as String?,
      sessionName: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceHistoryModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.pendingKey)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.sessionId)
      ..writeByte(3)
      ..write(obj.studentName)
      ..writeByte(4)
      ..write(obj.scanTime)
      ..writeByte(5)
      ..write(obj.syncStatus)
      ..writeByte(6)
      ..write(obj.error)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.syncedAt)
      ..writeByte(9)
      ..write(obj.studentQrCode)
      ..writeByte(10)
      ..write(obj.educationalLevel)
      ..writeByte(11)
      ..write(obj.email)
      ..writeByte(12)
      ..write(obj.phone)
      ..writeByte(13)
      ..write(obj.parentPhoneNumber)
      ..writeByte(14)
      ..write(obj.sessionName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
