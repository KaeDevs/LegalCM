// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionModelAdapter extends TypeAdapter<SubscriptionModel> {
  @override
  final int typeId = 7;

  @override
  SubscriptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscriptionModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      tier: fields[2] as SubscriptionTier,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime?,
      isActive: fields[5] as bool,
      transactionId: fields[6] as String?,
      backupsUsedThisMonth: fields[7] as int,
      lastBackupReset: fields[8] as DateTime,
      hasAds: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SubscriptionModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.tier)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.transactionId)
      ..writeByte(7)
      ..write(obj.backupsUsedThisMonth)
      ..writeByte(8)
      ..write(obj.lastBackupReset)
      ..writeByte(9)
      ..write(obj.hasAds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubscriptionTierAdapter extends TypeAdapter<SubscriptionTier> {
  @override
  final int typeId = 8;

  @override
  SubscriptionTier read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SubscriptionTier.free;
      case 1:
        return SubscriptionTier.adFree;
      case 2:
        return SubscriptionTier.unlimited;
      default:
        return SubscriptionTier.free;
    }
  }

  @override
  void write(BinaryWriter writer, SubscriptionTier obj) {
    switch (obj) {
      case SubscriptionTier.free:
        writer.writeByte(0);
        break;
      case SubscriptionTier.adFree:
        writer.writeByte(1);
        break;
      case SubscriptionTier.unlimited:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionTierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
} 