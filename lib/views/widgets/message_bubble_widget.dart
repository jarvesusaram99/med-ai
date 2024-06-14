import 'package:medai/controller.dart/chat_controller.dart';
import 'package:medai/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;

class MessageBubble extends StatefulWidget {
  final String sender;
  final String message;

  const MessageBubble({super.key, required this.sender, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  FlutterTts flutterTts = FlutterTts();
  ChatController chatController = Get.find();
  RxBool isSpeaking = false.obs;
  changeStringFormat() {
    try {
      if (widget.message.contains("</details>")) {
        return widget.message.split("</details>").last;
      }
      return widget.message;
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.message);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: widget.sender == "user"
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.sender == "user" ? "You" : widget.sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4.0),
          Material(
            borderRadius: BorderRadius.circular(12.0),
            elevation: 1.0,
            color: widget.sender == "user"
                // 088395
                //569DAA
                ? TextColors.appPrimaryColor
                : Colors.blueGrey.shade900,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: widget.sender == "user"
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SelectableText(
                        changeStringFormat(),
                        showCursor: true,
                        scrollPhysics: const BouncingScrollPhysics(),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: widget.sender == "user"
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: MarkdownBody(
                              imageBuilder: (uri, title, alt) {
                                return Image.network(
                                  uri.toString(),
                                  fit: BoxFit.cover,
                                );
                              },
                              data: changeStringFormat(),
                              onTapLink: (text, href, title) async {},
                              extensionSet: md.ExtensionSet(
                                md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                                [
                                  md.EmojiSyntax(),
                                  ...md.ExtensionSet.gitHubFlavored
                                      .inlineSyntaxes
                                ],
                              ),
                              selectable: true,
                              styleSheet: MarkdownStyleSheet(
                                a: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                p: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                                code: const TextStyle(
                                  backgroundColor: Colors.transparent,
                                  fontSize: 12.0,
                                  color: Colors.lightBlueAccent,
                                ),
                                tableBody: const TextStyle(
                                  decorationColor: Colors.white10,
                                ),
                                tableHead: const TextStyle(
                                  backgroundColor: Colors.black,
                                  color: Colors.white,
                                ),
                                tableCellsDecoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.content_copy,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ),
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                  text: changeStringFormat(),
                                ));
                                Fluttertoast.showToast(
                                    msg: "Copied to clipboard");
                              },
                            ),
                            Obx(() => InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Icon(
                                      isSpeaking.value
                                          ? Icons.volume_up_rounded
                                          : Icons.volume_off_rounded,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                  ),
                                  onTap: () async {
                                    if (isSpeaking.value) {
                                      await flutterTts.stop();
                                      isSpeaking.value = false;
                                      return;
                                    }
                                    isSpeaking.value = true;

                                    // flutterTts.
                                    await flutterTts
                                        .speak(changeStringFormat());
                                    await flutterTts.awaitSpeakCompletion(true);
                                    isSpeaking.value = false;
                                  },
                                ))
                          ],
                        )
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}