// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_chat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SingleChatAdapter extends TypeAdapter<SingleChat> {
  @override
  final int typeId = 1;

  @override
  SingleChat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SingleChat(
      fields[0] as int,
      (fields[1] as List).cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SingleChat obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.messages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SingleChatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}