import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../models.dart/hive/all_chats.dart' as allchats;
import 'package:intl/intl.dart';

class RecentChatController extends GetxController {
  bool isDialogVisibled = false;
  @override
  void onInit() {
    getDataFromHive();
    super.onInit();
  }

  String formatChatTime(DateTime time) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final date = DateFormat('dd MMM').format(time);

    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return "Today";
    } else if (time.day == yesterday.day &&
        time.month == yesterday.month &&
        time.year == yesterday.year) {
      return "Yesterday";
    } else {
      return date;
    }
  }

  Map<String, List<allchats.Chat>> groupChatsByDate(
      List<allchats.Chat> chatsList) {
    final chatMap = <String, List<allchats.Chat>>{};

    for (final chat in chatsList) {
      final formattedTime = formatChatTime(chat.time);
      if (!chatMap.containsKey(formattedTime)) {
        chatMap[formattedTime] = [];
      }
      chatMap[formattedTime]!.add(chat);
    }

    return chatMap;
  }

  var chatsBox = Hive.box<allchats.Chat>("chatsbox");
  RxList<allchats.Chat> allChats = <allchats.Chat>[].obs;

  getDataFromHive() {
    // chatsBox.clear();
    allChats.value = chatsBox.values.toList();
  }
}