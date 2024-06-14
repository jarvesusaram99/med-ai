import 'package:hive/hive.dart';

part 'all_chats.g.dart';

@HiveType(typeId: 0)
class Chat extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String firstMessage;
  @HiveField(3)
  DateTime time;
  @HiveField(4)
  bool isPrompt;
  @HiveField(5)
  String promptDesc;

  Chat(
      {required this.id,
      required this.title,
      required this.firstMessage,
      required this.time,
      required this.isPrompt,
      required this.promptDesc});
}