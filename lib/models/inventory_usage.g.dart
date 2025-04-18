// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_usage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryUsageAdapter extends TypeAdapter<InventoryUsage> {
  @override
  final int typeId = 3; // Cambiado a 3 para evitar conflicto con InventoryItem

  @override
  InventoryUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryUsage(
      id: fields[0] as String,
      inventoryItemId: fields[1] as String,
      recipeId: fields[2] as String,
      quantity: fields[3] as double,
      date: fields[4] as DateTime,
      nombre: fields[5] as String,
      unidad: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryUsage obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.inventoryItemId)
      ..writeByte(2)
      ..write(obj.recipeId)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.nombre)
      ..writeByte(6)
      ..write(obj.unidad);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
