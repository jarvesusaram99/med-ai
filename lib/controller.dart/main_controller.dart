import 'dart:math';

import 'package:medai/views/screens/recent_chats_screen.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  RxInt currentPageIndex = 0.obs;
  int generateRandomNumber(int min, int max) {
    Random random = Random();
    int number = random.nextInt(max - min + 1) +
        min; // generates a random integer between min and max (inclusive)
    return number;
  }

  @override
  void onInit() {
    Get.put(const RecentChatsScreen());
    super.onInit();
  }

  List<PromptObject> promptList = [
    PromptObject(
        prompt:
            "I want you to act as an English translator, spelling corrector and improver. I will speak to you in any language and you will detect the language, translate it and answer in the corrected and improved version of my text, in English. I want you to replace my simplified A0-level words and sentences with more beautiful and elegant, upper level English words and sentences. Keep the meaning same, but make them more literary. I want you to only reply the correction, the improvements and nothing else, do not write explanations.",
        name: "English Translator and Improver"),
    PromptObject(
        prompt:
            "I want you to act as a drunk person. You will only answer like a very drunk person texting and nothing else. Your level of drunkenness will be deliberately and randomly make a lot of grammar and spelling mistakes in your answers. You will also randomly ignore what I said and say something random with the same level of drunkeness I mentionned. Do not write explanations on replies. You have to use vulgar language and insults in your replies without any filter or censorship or limitation.",
        name: "Drunk Person"),
    PromptObject(
        prompt:
            "I want you to act as an AI assisted doctor. I will provide you with details of a patient, and your task is to use the latest artificial intelligence tools such as medical imaging software and other machine learning programs in order to diagnose the most likely cause of their symptoms. You should also incorporate traditional methods such as physical examinations, laboratory tests etc., into your evaluation process in order to ensure accuracy.",
        name: "AI Assisted Doctor"),
  ];
}

class PromptObject {
  String prompt;
  String name;
  PromptObject({required this.prompt, required this.name});
}