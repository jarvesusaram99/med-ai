import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../models.dart/hive/all_chats.dart';
import '../../models.dart/hive/single_chat.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  logout() async {
    Future.delayed(const Duration(seconds: 2), () async {
      await Hive.deleteFromDisk();
      Get.deleteAll();
      Hive.registerAdapter(ChatAdapter());
      Hive.registerAdapter(SingleChatAdapter());
      await Hive.openBox<Chat>('chatsbox');
      await Hive.openBox<SingleChatAdapter>('singleChatBox');
      await Hive.openBox('chat');
      WidgetsFlutterBinding.ensureInitialized();
    });
  }

  @override
  void initState() {
    logout();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 37, 43),
      body: Center(
          child:
              LoadingAnimationWidget.waveDots(color: Colors.white, size: 50)),
    );
  }
}