import 'dart:developer' as logger;
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:medai/views/screens/main_screen.dart';
import 'package:medai/views/screens/recent_chats_screen.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class MainController extends GetxController {
  RxInt currentPageIndex = 0.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    Get.put(const RecentChatsScreen());
    super.onInit();
  }

  int generateRandomNumber(int min, int max) {
    Random random = Random();
    int number = random.nextInt(max - min + 1) + min;
    return number;
  }

  String pdfContent = "";
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
    PromptObject(prompt: '''''', name: "Chat with your report"),
  ];

  Future<bool> pdfPicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      String pdfContent = await getPDFtext(file.path);
      int estimatedPages = estimatePages(pdfContent);
      if (estimatedPages < 3) {
        if (isMedicalContent(pdfContent)) {
          pdfContent = removeRedundancy(pdfContent);
          promptList.last = PromptObject(
            prompt:
                '''I want you to act as an AI-assisted doctor specializing in patient diagnosis. I will provide you with the extracted text content of a patient's PDF medical report. Your task is to:
Identify and summarize the patient's basic information (name, age, gender, collection date, report status, etc.).
Determine the type of report (e.g., thyroid profile, diabetic panel, lipid profile, etc.).
Analyze the test results and compare them with the biological reference intervals.
Incorporate traditional diagnostic methods such as physical examination findings, laboratory tests, and clinical guidelines to ensure the accuracy and comprehensiveness of your evaluation.
Provide a detailed diagnosis and recommend potential treatment options based on your integrated analysis.
Example Input: "$pdfContent" ''',
            name: "Chat with your report",
          );
        } else {
          flutterToast("The selected report does not contain medical content.");
          isLoading.value = false;

          return false;
        }
      } else {
        flutterToast(
            'The selected report is too lengthy. Please select a shorter report.');
        isLoading.value = false;

        return false;
      }
    } else {
      flutterToast('Please select a PDF file to continue.');
      isLoading.value = false;
      return false;
    }
    return true;
  }

  Future<String> getPDFtext(String path) async {
    try {
      pdfContent = await ReadPdfText.getPDFtext(path);
      return pdfContent;
    } on PlatformException {
      flutterToast(
          "An error occurred while reading the PDF file. Please try again.");
      isLoading.value = false;

      await Get.off(() => const MainScreen());
    }
    return "";
  }

  int estimatePages(String text) {
    const int avgCharsPerPage = 2500;

    return (text.length / avgCharsPerPage).ceil();
  }

  bool isMedicalContent(String text) {
    List<String> medicalKeywords = [
      "patient",
      "diagnosis",
      "treatment",
      "prescription",
      "test",
      "results",
      "lab",
      "report"
    ];
    for (var keyword in medicalKeywords) {
      if (text.toLowerCase().contains(keyword.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  String removeRedundancy(String text) {
    Set<String> uniqueLines = {};
    List<String> lines = text.split('\n');
    for (String line in lines) {
      uniqueLines.add(line.trim());
    }
    return uniqueLines.join('\n');
  }

  flutterToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      fontSize: 16.0,
    );
  }
}

class PromptObject {
  String prompt;
  String name;
  PromptObject({required this.prompt, required this.name});
}
