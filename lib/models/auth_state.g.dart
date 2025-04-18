// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthStateAdapter extends TypeAdapter<AuthState> {
  @override
  final int typeId = 2;

  @override
  AuthState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthState(
      userId: fields[0] as String,
      lastLogin: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AuthState obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.lastLogin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
