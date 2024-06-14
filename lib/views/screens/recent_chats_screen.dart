import 'package:medai/controller.dart/recent_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller.dart/chat_controller.dart';
import '../../utils/colors.dart';

class RecentChatsScreen extends StatefulWidget {
  const RecentChatsScreen({super.key});

  @override
  State<RecentChatsScreen> createState() => _RecentChatsScreenState();
}

class _RecentChatsScreenState extends State<RecentChatsScreen> {
  RecentChatController recentChatController = Get.put(RecentChatController());
  final timeFormat = DateFormat('MMMM d');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: TextColors.backgroundColor,
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    if (recentChatController.allChats.isEmpty) {
                      return SizedBox(
                        height: Get.height * 0.7,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                                alignment: Alignment.center,
                                child: Text("No Chat yet!")),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      reverse: true,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(0),
                      shrinkWrap: true,
                      itemCount: recentChatController.allChats.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () async {
                            print(recentChatController
                                .allChats[index].promptDesc);
                            Get.put(ChatController()).chatIndex = index;
                            Get.put(ChatController()).chatBoxId =
                                recentChatController.allChats[index].id;
                            Get.find<ChatController>().isChatAdded.value = true;

                            Get.find<ChatController>().isPromptChat.value =
                                recentChatController.allChats[index].isPrompt;
                            Get.find<ChatController>().promptDescriptio =
                                recentChatController.allChats[index].promptDesc;

                            await Get.find<ChatController>().openHiveBox();
                            await Get.find<ChatController>().getChatMessages(
                                recentChatController.allChats[index].id);
                            Get.find<ChatController>()
                                    .titleTextEditingController
                                    .text =
                                recentChatController.allChats[index].title;

                            Get.toNamed("/chatScreen")!.then((value) =>
                                Get.find<RecentChatController>()
                                    .getDataFromHive());
                          },
                          child: ListTile(
                            trailing: Text(
                                timeFormat.format(
                                    recentChatController.allChats[index].time),
                                style: const TextStyle(color: Colors.white54),
                                overflow: TextOverflow.ellipsis),
                            title: SizedBox(
                              width: Get.width * 0.6,
                              child: Text(
                                recentChatController.allChats[index].title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            subtitle: Text(
                              recentChatController.allChats[index].firstMessage,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ),
                        );
                      },
                    );
                  })
                ]),
          ),
        ));
  }
}