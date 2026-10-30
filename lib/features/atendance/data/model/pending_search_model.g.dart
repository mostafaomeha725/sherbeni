// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_search_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingSearchModelAdapter extends TypeAdapter<PendingSearchModel> {
  @override
  final int typeId = 8;

  @override
  PendingSearchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingSearchModel(
      pendingKey: fields[0] as String,
      searchValue: fields[1] as String,
      sessionId: fields[2] as String,
      sessionName: fields[3] as String,
      status: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PendingSearchModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.pendingKey)
      ..writeByte(1)
      ..write(obj.searchValue)
      ..writeByte(2)
      ..write(obj.sessionId)
      ..writeByte(3)
      ..write(obj.sessionName)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingSearchModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
