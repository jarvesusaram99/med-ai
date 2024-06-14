import 'dart:developer';

import 'package:medai/controller.dart/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../widgets/message_bubble_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.find<ChatController>();

  @override
  void initState() {
    chatController.initWebSocket();
    chatController.scrollController.keepScrollOffset;
    chatController.scrollController.addListener(() {
      if (chatController.scrollController.position.pixels < 60) {
        isAtTop.value = true;
      } else {
        isAtTop.value = false;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    chatController.channel.sink.close();
    chatController.textController.dispose();
    chatController.focusNode.dispose();
    chatController.scrollController.dispose();
    chatController.titleTextEditingController.dispose();
    chatController.searchTextEditingController.dispose();
    chatController.appBarTextFieldfocusNode.dispose();
    Get.delete<ChatController>();
    super.dispose();
  }

  RxBool isAtTop = false.obs;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.blueGrey.shade900),
    );
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 37, 43),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey.shade900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (chatController.isTitleEdit.value ||
                chatController.isSearch.value) {
              chatController.isTitleEdit.value = false;
              chatController.isSearch.value = false;
              return;
            }
            Get.back();
          },
        ),
        title: Obx(
          () => chatController.isTitleEdit.value ||
                  chatController.isSearch.value
              ? TextField(
                  focusNode: chatController.appBarTextFieldfocusNode,
                  onSubmitted: (value) {
                    print("onSubmitted: $value");
                    if (chatController.isSearch.value) {
                      List<dynamic> results = chatController.messages
                          .where((element) =>
                              element["message"]
                                  ?.toString()
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ??
                              false)
                          .toList();

                      results = results.map((message) {
                        if (message is String) {
                          return message;
                        }
                        String messageText = message["message"] ?? '';
                        if (messageText.contains("</details>")) {
                          log(messageText.split("</details>").last);
                          return messageText.split("</details>").last;
                        }
                        log(messageText);
                        return messageText;
                      }).toList();

                      print("result length: ${results.length}");
                    } else {
                      print("rename chat title");
                      chatController.renameChatTitle();
                      chatController.isTitleEdit.value = false;
                    }
                  },
                  controller: chatController.isSearch.value
                      ? chatController.searchTextEditingController
                      : chatController.titleTextEditingController,
                  style:
                      const TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),
                  decoration: InputDecoration(
                      isDense: true,
                      // contentPadding: EdgeInsets.only(top: 16),
                      hintText: chatController.isSearch.value
                          ? "Search"
                          : "Add title to chat",
                      hintStyle:
                          const TextStyle(color: Colors.white54, fontSize: 16),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white70, width: 1)),
                      border: const UnderlineInputBorder()),
                )
              : Text(chatController.titleTextEditingController.text),
        ),
        actions: [
          Obx(() =>
              chatController.isTitleEdit.value || chatController.isSearch.value
                  ? chatController.isSearch.value
                      ? Row(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.keyboard_arrow_down)),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.keyboard_arrow_up)),
                          ],
                        )
                      : IconButton(
                          onPressed: () {
                            print("rename chat title");
                            chatController.renameChatTitle();
                            chatController.isTitleEdit.value = false;
                            chatController.isTitleEdit.value = false;
                          },
                          icon: const Icon(Icons.done))
                  : Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: Colors.blueGrey.shade900,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(0),
                        child: PopupMenuButton<int>(
                          padding: const EdgeInsets.all(0),
                          tooltip: "Options",
                          key: chatController.popupMenuGlobalKey,
                          itemBuilder: (context) {
                            return <PopupMenuEntry<int>>[
                              PopupMenuItem(
                                value: 0,
                                child: const Text('Rename'),
                                onTap: () {
                                  chatController.isTitleEdit.value = true;
                                  chatController.appBarTextFieldfocusNode
                                      .requestFocus();
                                },
                              ),
                              // PopupMenuItem(
                              //   value: 0,
                              //   child: const Text('Search'),
                              //   onTap: () {
                              //     chatController.isSearch.value = true;
                              //     chatController.appBarTextFieldfocusNode
                              //         .requestFocus();
                              //   },
                              // ),
                              PopupMenuItem(
                                  onTap: () {
                                    chatController.clearChat();
                                  },
                                  value: 1,
                                  child: const Text('Clear Chat')),
                              PopupMenuItem(
                                value: 1,
                                child: const Text('Delete Chat'),
                                onTap: () {
                                  chatController.deleteChat();
                                  Get.back();
                                },
                              ),
                            ];
                          },
                          onSelected: (result) {},
                          offset: const Offset(10, 10),
                        ),
                      ),
                    )),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              GetBuilder<ChatController>(
                builder: (controller) => controller.messages.isEmpty
                    ? Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              chatController.getRandomGreeting(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        child: Scrollbar(
                          controller: controller.scrollController,
                          scrollbarOrientation: ScrollbarOrientation.right,
                          trackVisibility: true,
                          interactive: true,
                          child: ListView.builder(
                            controller: controller.scrollController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: controller.messages.length,
                            itemBuilder: (context, index) {
                              var message = controller.messages[index];
                              if (index == controller.messages.length - 1) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    MessageBubble(
                                      sender: message["sender"],
                                      message: () {
                                        if (message["message"]
                                            .contains("</details>")) {
                                          return message["message"]
                                              .split("</details>")
                                              .last;
                                        }
                                        return message["message"];
                                      }(),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              }
                              return MessageBubble(
                                sender: message["sender"],
                                message: message["message"],
                              );
                            },
                          ),
                        ),
                      ),
              ),
              Obx(() => chatController.isTitleEdit.value ||
                      chatController.isSearch.value
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade900,
                        borderRadius: const BorderRadius.only(
                            // topLeft: Radius.circular(10.0),
                            // topRight: Radius.circular(10.0),
                            ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      height: 60.0,
                      child: Row(
                        children: <Widget>[
                          Obx(
                            () => chatController.isListening.value
                                ? IconButton(
                                    onPressed: () {
                                      chatController.isListening.value = false;
                                    },
                                    icon: LoadingAnimationWidget
                                        .staggeredDotsWave(
                                            color: Colors.white, size: 24))
                                : Material(
                                    color: Colors.blueGrey.shade900,
                                    child: IconButton(
                                        highlightColor: Colors.transparent,
                                        tooltip: "Voice Input",
                                        onPressed: () {
                                          if (chatController
                                              .isListening.value) {
                                            chatController.stopListening();
                                          } else {
                                            chatController.startListening();
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.mic_rounded,
                                          color: Colors.white70,
                                          size: 25,
                                        )),
                                  ),
                          ),
                          Expanded(
                            child: TextField(
                              focusNode: chatController.focusNode,
                              controller: chatController.textController,
                              onChanged: (value) {
                                // remove first and last whitespace
                                value = value.trim();
                              },
                              keyboardAppearance: Brightness.dark,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                isDense: true,
                                hintText: "Ask me anything...",
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 17),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          chatController.isSocketDataLoading.value
                              ? Padding(
                                  padding:
                                      const EdgeInsets.only(right: 10, top: 10),
                                  child: SizedBox(
                                    height: 20,
                                    width: 30,
                                    child: LoadingAnimationWidget.waveDots(
                                        color: Colors.white70, size: 35),
                                  ),
                                )
                              : IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  tooltip: "Send",
                                  onPressed: () {
                                    if (chatController
                                        .textController.text.isEmpty) {
                                      return;
                                    }
                                    if (chatController.isFileUrl(
                                        chatController.textController.text,
                                        chatController.fileExtensions)) {
                                      Fluttertoast.showToast(
                                          msg:
                                              "File Urls are not supported in this model");
                                      chatController.textController.text =
                                          chatController.textController.text;
                                      return;
                                    }
                                    chatController.sendMessage(
                                        chatController.textController.text);

                                    chatController.textController.clear();
                                  },
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.white70,
                                    size: 25,
                                  )),
                        ],
                      ),
                    )),
            ],
          ),

          // check whether user is on top of the chat or not
          // if not then show a button to scroll to bottom
          Obx(() {
            return isAtTop.value
                ? Positioned(
                    bottom: 70,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        chatController.scrollController.animateTo(
                            chatController
                                .scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                            color: Colors.black, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_downward_sharp),
                      ),
                    ),
                  )
                : Container();
          })
        ],
      ),
    );
  }
}