import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:medai/controller.dart/main_controller.dart';
import 'package:medai/controller.dart/recent_chat_controller.dart';
import 'package:medai/utils/colors.dart';
import 'package:medai/views/screens/home_screen.dart';
import 'package:medai/views/screens/recent_chats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controller.dart/chat_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin<MainScreen> {
  MainController mainController = Get.put(MainController());

  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.blueGrey.shade900),
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey.shade900,
        title: GestureDetector(onTap: () {}, child: const Text("Med AI")),
        actions: const [],
      ),
      floatingActionButton: Theme(
          data: ThemeData(
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.blueGrey.shade900,
            ),
          ),
          child: 1 == 2
              ? InkWell(
                  onTap: () {
                    Get.put(ChatController()).chatBoxId =
                        mainController.generateRandomNumber(1, 30000);
                    // Get.find<ChatController>().isOldChat.value = false;
                    Get.find<ChatController>().chatIndex =
                        Get.find<RecentChatController>().allChats.isEmpty
                            ? 0
                            : Get.find<RecentChatController>().allChats.length;
                    // Get.find<ChatController>()
                    Get.find<ChatController>().openHiveBox();
                    Get.find<ChatController>()
                        .titleTextEditingController
                        .text = Get.find<RecentChatController>()
                            .allChats
                            .isEmpty
                        ? "Conversation 1"
                        : "Conversation ${Get.find<RecentChatController>().allChats.length + 1}";

                    // Get.find<ChatController>().textController.text =
                    //     mainController.promptList[index].prompt;

                    Get.toNamed("/chatScreen")!.then((value) =>
                        Get.find<RecentChatController>().getDataFromHive());
                    Get.find<ChatController>().focusNode.requestFocus();
                  },
                  child: Container(
                    width: 60,
                    height: 50,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          spreadRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      // shape: BoxShape.circle,
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.blueGrey.shade900,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LottieBuilder.asset(
                        "assets/lottie/chatbot final.json",
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                )
              : FloatingActionButton.extended(
                  icon: LottieBuilder.asset(
                    "assets/lottie/chatbot final.json",
                    height: 40,
                    width: 40,
                  ),
                  onPressed: () async {
                    Get.put(ChatController()).chatBoxId =
                        mainController.generateRandomNumber(1, 30000);
                    Get.find<ChatController>().chatIndex =
                        Get.find<RecentChatController>().allChats.isEmpty
                            ? 0
                            : Get.find<RecentChatController>().allChats.length;
                    Get.find<ChatController>().openHiveBox();
                    Get.find<ChatController>()
                        .titleTextEditingController
                        .text = Get.find<RecentChatController>()
                            .allChats
                            .isEmpty
                        ? "Conversation 1"
                        : "Conversation ${Get.find<RecentChatController>().allChats.length + 1}";

                    Get.toNamed("/chatScreen")!.then((value) =>
                        Get.find<RecentChatController>().getDataFromHive());
                  },
                  label: const Text(
                    "Start Chat",
                    style: TextStyle(color: Colors.white),
                  ),
                )),
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: TextColors.backgroundColor,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SegmentedTabControl(
                  controller: tabController,
                  radius: const Radius.circular(12),
                  indicatorColor: TextColors.appPrimaryColor,
                  squeezeIntensity: 1,
                  height: 45,
                  tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                  tabs: [
                    SegmentTab(
                      backgroundColor: TextColors.appBarBackgroundColor,
                      label: 'Explore',
                    ),
                    SegmentTab(
                      backgroundColor: TextColors.appBarBackgroundColor,
                      label: 'Chats',
                    ),
                  ],
                ),
              ),
              // Sample pages
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: TabBarView(
                  controller: tabController,
                  physics: const ClampingScrollPhysics(),
                  children: const [
                    HomeScreen(),
                    RecentChatsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}