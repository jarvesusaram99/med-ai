import 'package:hive/hive.dart';

part 'single_chat.g.dart';

@HiveType(typeId: 1)
class SingleChat extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final List<dynamic> messages;

  SingleChat(this.id, this.messages);
}