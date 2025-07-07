// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeEntryModelAdapter extends TypeAdapter<TimeEntryModel> {
  @override
  final int typeId = 4;

  @override
  TimeEntryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeEntryModel(
      id: fields[0] as String,
      caseId: fields[1] as String,
      date: fields[2] as DateTime,
      description: fields[3] as String,
      hours: fields[4] as double,
      rate: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TimeEntryModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.caseId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.hours)
      ..writeByte(5)
      ..write(obj.rate)
      ..writeByte(6)
      ..write(obj.total);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeEntryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
