// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_chats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatAdapter extends TypeAdapter<Chat> {
  @override
  final int typeId = 0;

  @override
  Chat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chat(
      id: fields[0] as int,
      title: fields[1] as String,
      firstMessage: fields[2] as String,
      time: fields[3] as DateTime,
      isPrompt: fields[4] as bool,
      promptDesc: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Chat obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.firstMessage)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.isPrompt)
      ..writeByte(5)
      ..write(obj.promptDesc);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}