import 'package:medai/controller.dart/main_controller.dart';
import 'package:medai/controller.dart/recent_chat_controller.dart';
import 'package:medai/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller.dart/chat_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RecentChatController recentChatController = Get.put(RecentChatController());
  final timeFormat = DateFormat('MMMM d');

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blueGrey.shade900,
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding:
                              EdgeInsets.only(top: 18, left: 10, right: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Prompts ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                              top: 10, left: 10, right: 30, bottom: 13),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Play with our chatbot with some famous prompts to get started with.",
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                Get.find<MainController>().promptList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Get.put(ChatController()).chatBoxId =
                                        Get.find<MainController>()
                                            .generateRandomNumber(1, 30000);
                                    // Get.find<ChatController>().isOldChat.value = false;
                                    Get.find<ChatController>().chatIndex =
                                        Get.find<RecentChatController>()
                                                .allChats
                                                .isEmpty
                                            ? 0
                                            : Get.find<RecentChatController>()
                                                .allChats
                                                .length;
                                    // Get.find<ChatController>()
                                    Get.find<ChatController>().openHiveBox();
                                    Get.find<ChatController>()
                                            .titleTextEditingController
                                            .text =
                                        Get.find<MainController>()
                                            .promptList[index]
                                            .name;

                                    Get.find<ChatController>()
                                            .promptDescriptio =
                                        "${Get.find<MainController>().promptList[index].prompt}  请用 markdown 格式输出。\n";
                                    Get.find<ChatController>()
                                        .isPromptChat
                                        .value = true;

                                    Get.toNamed("/chatScreen")!.then((value) =>
                                        Get.find<RecentChatController>()
                                            .getDataFromHive());
                                    // Get.toNamed("/journalEntry");
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 18,
                                        bottom: 16,
                                        left: 10,
                                        right: 10),
                                    child: Row(children: [
                                      Text(
                                        Get.find<MainController>()
                                            .promptList[index]
                                            .name,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                    ]),
                                  ),
                                ),
                              );
                            }),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}