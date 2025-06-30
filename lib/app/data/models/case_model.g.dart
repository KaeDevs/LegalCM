// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CaseModelAdapter extends TypeAdapter<CaseModel> {
  @override
  final int typeId = 0;

  @override
  CaseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CaseModel(
      id: fields[0] as String,
      title: fields[1] as String,
      clientName: fields[2] as String,
      court: fields[3] as String,
      courtNo: fields[4] as String,
      status: fields[5] as String,
      nextHearing: fields[6] as DateTime,
      notes: fields[7] as String,
      clientId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CaseModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.clientName)
      ..writeByte(3)
      ..write(obj.court)
      ..writeByte(4)
      ..write(obj.courtNo)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.nextHearing)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.clientId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
