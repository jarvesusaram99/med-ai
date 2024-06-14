import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:medai/controller.dart/recent_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:web_socket_channel/io.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../models.dart/hive/all_chats.dart' as allchats;

class ChatController extends GetxController {
  RxBool isPromptChat = false.obs;
  String promptDescriptio = "";
  int chatBoxId = 0;
  RxBool isChatAdded = false.obs;
  int? chatIndex;
  RxBool isSearch = false.obs;
  RxBool isTitleEdit = false.obs;
  final isSocketDataLoading = RxBool(false);
  RxBool isStopStream = false.obs;
  RxBool isMaxScroll = false.obs;
  final isMessageLoading = RxBool(false);
  final RxBool isListening = false.obs;
  final stt.SpeechToText speechToText = stt.SpeechToText();
  FocusNode focusNode = FocusNode();
  FocusNode appBarTextFieldfocusNode = FocusNode();
  final GlobalKey<PopupMenuButtonState<int>> popupMenuGlobalKey = GlobalKey();
  ScrollController scrollController = ScrollController();
  final TextEditingController textController = TextEditingController();
  late IOWebSocketChannel channel;
  StreamSubscription? _subscription;
  List<dynamic> messages = [];
  String chatData = "";
  String _messageBuffer = "";
  RxBool isPlaying = false.obs;
  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController searchTextEditingController = TextEditingController();
  late Box chatbox;

  static Map<String, String> headers = {
    'Pragma': 'no-cache',
    'Cache-Control': 'no-cache',
    'User-Agent':
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36',
    'Accept-Language': 'en-US,en;q=0.8',
    'Upgrade': 'websocket',
    'Origin': 'https://ai.zyinfo.pro',
    'Sec-WebSocket-Version': '13',
    'Accept-Encoding': 'gzip, deflate, br',
    'Sec-WebSocket-Key': 'OiflS8nX5PraRDp29/zvPQ==',
    'Sec-WebSocket-Extensions': 'permessage-deflate; client_max_window_bits',
  };
  List<String> greetingMessages = [
    "Hello! How can I assist you today?",
    "Hi there! What can I help you with?",
    "Greetings! How may I be of service?",
    "Hey! How can I help you?",
    "Welcome! What can I do for you?",
  ];
  String getRandomGreeting() {
    final random = Random();
    final index = random.nextInt(greetingMessages.length);
    return greetingMessages[index];
  }

  bool isFileUrl(String url, List<String> fileExtensions) {
    final lowerCaseUrl = url.toLowerCase();

    // Split the URL into the base URL and any query string parameters
    final parts = lowerCaseUrl.split('?');
    final baseUrl = parts.first;

    for (final extension in fileExtensions) {
      if (baseUrl.endsWith('.$extension')) {
        return true;
      }
    }

    return false;
  }

  final fileExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx'
  ];

  bool isChinese(String text) {
    RegExp regExp = RegExp(r'[\u4e00-\u9fa5]');
    return regExp.hasMatch(text);
  }

  showDialogBox() {
    return showDialog(
      context: Get.context!,
      builder: (context) {
        Get.find<RecentChatController>().isDialogVisibled = true;
        return AlertDialog(
          title: const Text("Chatbot Waring"),
          content: const Text(
              "Sometime chatbot may not reply in english. In that case, ask like this (Reply above in english)."),
          actions: [
            TextButton(
              onPressed: () {
                Get.find<RecentChatController>().isDialogVisibled = true;
                Get.back();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

//  --------------- Hive Localdatabase  ----------------
  openHiveBox() async {
    var boxName = 'chatbox $chatBoxId';
    chatbox = await Hive.openBox(boxName);
  }

  addChatDetailsToHive(String message) {
    if (!isChatAdded.value) {
      print("chatBoxId $chatBoxId");
      Get.find<RecentChatController>().chatsBox.add(allchats.Chat(
          id: chatBoxId,
          title: titleTextEditingController.text,
          firstMessage: message,
          time: DateTime.now(),
          isPrompt: isPromptChat.value,
          promptDesc: promptDescriptio));
      isChatAdded.value = true;
      print(
          "Get.find<RecentChatController>().chatsBox.length ${Get.find<RecentChatController>().chatsBox.length}");
    } else {
      updateChatDate(message);
    }
  }

  clearChat() {
    messages = [];
    chatData = "";
    chatbox.clear();
    update();

    Get.find<RecentChatController>().chatsBox.putAt(
        chatIndex!,
        allchats.Chat(
            id: chatBoxId,
            title: titleTextEditingController.text,
            firstMessage: "",
            time: DateTime.now(),
            isPrompt: isPromptChat.value,
            promptDesc: promptDescriptio));
  }

  deleteChat() {
    messages = [];
    chatData = "";
    chatbox.clear();
    Get.find<RecentChatController>().chatsBox.deleteAt(chatIndex!);
    update();
  }

  renameChatTitle() async {
    var firstMessage = Get.find<RecentChatController>()
        .chatsBox
        .getAt(chatIndex!)!
        .firstMessage;
    Get.find<RecentChatController>().chatsBox.putAt(
        chatIndex!,
        allchats.Chat(
            id: chatBoxId,
            title: titleTextEditingController.text,
            firstMessage: firstMessage,
            time: DateTime.now(),
            isPrompt: isPromptChat.value,
            promptDesc: promptDescriptio));
  }

  updateChatDate(String message) {
    // print(messages.l);
    var firstMessage = Get.find<RecentChatController>()
        .chatsBox
        .getAt(chatIndex!)!
        .firstMessage;
    Get.find<RecentChatController>().chatsBox.putAt(
        chatIndex!,
        allchats.Chat(
            id: chatBoxId,
            title: titleTextEditingController.text,
            firstMessage: firstMessage == "" ? message : firstMessage,
            time: DateTime.now(),
            isPrompt: isPromptChat.value,
            promptDesc: promptDescriptio));
  }

  saveMessagesToHive() {
    chatbox.put("messages", messages);
  }

  getChatMessages(id) async {
    var boxName = 'chatbox $chatBoxId';
    chatbox = Hive.box(boxName);
    chatbox.get("messages") == null
        ? messages = []
        : messages = chatbox.get("messages");
    update();
  }

// -------------------------Socket Start ------------

  void initWebSocket() async {
    try {
      channel = IOWebSocketChannel.connect(
        Uri.parse('wss://v.stylee.top:8883/ws_webapi'),
        headers: headers,
      );
      _subscription = channel.stream.listen(
        (data) {
          // print(data);
          if (isChinese(data) &&
              Get.find<RecentChatController>().isDialogVisibled == false) {
            showDialogBox();
            Get.find<RecentChatController>().isDialogVisibled = true;
          }
          // debugPrint("Data received: $data");
          handleIncomingMessage(data);
        },
        onDone: () {
          print("Done");
          isSocketDataLoading.value = false;
        },
        cancelOnError: true,
        onError: (error, StackTrace stackTrace) {
          Fluttertoast.showToast(msg: "Socket error: $error");
          print("Socket error: $error");
          print(stackTrace);
          isSocketDataLoading.value = false;
        },
      );
    } catch (e) {
      print('Error connecting to socket: $e');
      Fluttertoast.showToast(msg: "Error connecting to socket: $e");
      isSocketDataLoading.value = false;
    } finally {
      isSocketDataLoading.value = false;
    }
  }

  Future stopSocket() async {
    isStopStream.value = true;

    try {
      _subscription
          ?.cancel(); // cancel the subscription to stop listening to incoming messages
      await channel.sink.close(WebSocketStatus.goingAway, 'Forced close');
      print('Socket closed.');
      print(channel.closeCode);
      print(channel.closeReason);
    } catch (e) {
      print('Error closing socket: $e');
    }
    isStopStream.value = false;
  }

  void handleIncomingMessage(dynamic data) {
    // print("data $data");
    _messageBuffer += data;
    var maxScrolled = false;
    bool isOnlyScrollOne = true;
    try {
      if (isOnlyScrollOne) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
        isOnlyScrollOne = false;
      }
      if (scrollController.position.maxScrollExtent <
          scrollController.position.pixels + 80) {
        maxScrolled = true;
      }
    } catch (e) {
      print("error in scrollController");
    }

    if (_messageBuffer == '') {
      return;
    }
    try {
      if (_messageBuffer.endsWith("ALL-finished!")) {
        _messageBuffer = _messageBuffer.replaceAll("ALL-finished!", "");
      }

      if (_messageBuffer == data) {
        messages.add({
          "sender": "bot",
          "message": _messageBuffer,
        });

        setDatatoMsg();
        addChatDetailsToHive(chatData);
        //
      } else {
        messages[messages.length - 1]["message"] = _messageBuffer;
      }
      if (data == 'ALL-finished!') {
        _messageBuffer = "";
        isSocketDataLoading.value = false;
      }
    } catch (e) {
      print("Incomplete message: $_messageBuffer");
    }
    if (maxScrolled) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }

    saveMessagesToHive();
    update();
  }

  void sendMessage(String message) async {
    print("message: $message");
    if (isFileUrl(message, fileExtensions)) {
      Fluttertoast.showToast(msg: "File Urls are not supported in this model");
      textController.text = message;
      return;
    }

    isSocketDataLoading.value = true;

    messages.add({
      "sender": "user",
      "message": message,
    });
    if (messages.length > 1) {
      if (scrollController.position.pixels !=
          scrollController.position.maxScrollExtent) {
        Future.delayed(const Duration(milliseconds: 500))
            .then((value) => scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ));
      }
    }

    setDatatoMsg();
    addChatDetailsToHive(message);
    saveMessagesToHive();

    final data = isPromptChat.value
        ? {
            "openid": "zyinfoai",
            "userid": "1682517574596",
            "q": chatData,
            "process_type": "simple"
          }
        : {
            "openid": "zyinfoai",
            "userid": "user1683222010614",
            "q": chatData,
            "process_type": "webchat",
            "last_prompt": message,
            "app": "agi-web",
            "model": "",
            "doc_id": "",
            "relate_file_db": ""
          };
    print("datasssss $data");
    channel.sink.add(json.encode(data));

    try {
      await channel.sink.done; // Wait until the message is sent successfully
    } catch (e) {
      isSocketDataLoading.value = false;
      Fluttertoast.showToast(msg: "Error sending message: $e");
      print("Error sending message: $e");
    }

    update();
  }

  setDatatoMsg() {
    chatData = isPromptChat.value
        ? promptDescriptio
        : "Q: Keep in mind, always reply me in English , as i don't  no chineese\nA:\nOk, Sure, I will always reply to you in English as per your request. ";
    for (var message in messages) {
      print(message);
      if (message['sender'] == 'user') {
        chatData += "\nQ:${message['message']}\nA:\n";
      } else {
        chatData += "${message['message']}\n\n";
      }
    }
    update();
  }

  //  ------------------ Speech to text  ----------------------

  Future<bool> initializeSpeechRecognition() async {
    bool available = await speechToText.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        status == 'notListening' ? isListening.value = false : null;
      },
      onError: (error) {
        print('Speech error: $error');
      },
    );
    return available;
  }

  Future<void> startListening() async {
    if (!isListening.value) {
      bool available = await initializeSpeechRecognition();
      if (available) {
        isListening.value = true;
        focusNode.requestFocus();
        speechToText.listen(
          onResult: (result) {
            String text = result.recognizedWords;
            String currentText = textController.text;
            if (result.finalResult) {
              textController.text = "$currentText $text";
              textController.text = textController.text.trim();
              textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textController.text.length));
            }
          },
        );
      }
    }
  }

  void stopListening() {
    speechToText.hasError ? isListening.value = false : null;
    speechToText.stop();
    isListening.value = false;
  }
}