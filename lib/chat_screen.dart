import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_widget.dart';
import 'constants/api.dart';

class ChatPage extends StatefulWidget {
  static const routeName = '/chat';
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _chatHistory = [];
  String? _file;
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  late final ChatSession _chat;
  late FocusNode focusNode;
  bool _isTyping = false;

  void getAnswer(text) async {
    _scrollController.jumpTo(0);
    setState(() {
      _isTyping = true;
    });
    late final GenerateContentResponse response;
    if (_file != null) {
      final firstImage = await (File(_file!).readAsBytes());
      final prompt = TextPart(text);
      final imageParts = [
        DataPart('image/jpeg', firstImage),
      ];

      response = await _visionModel.generateContent([
        Content.multi([prompt, ...imageParts])
      ]);
      _file = null;
    } else {
      var content = Content.text(text.toString());
      response = await _chat.sendMessage(content);
    }
    setState(() {
      _chatHistory.add({
        "time": DateTime.now(),
        "message": response.text,
        "isSender": false,
        "isImage": false
      });
      _file = null;
      _isTyping = false;
    });
    _scrollController.jumpTo(0);
  }

  @override
  void initState() {
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    _visionModel = GenerativeModel(model: 'gemini-pro-vision', apiKey: apiKey);
    _chat = _model.startChat();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(
            Icons.chat,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "VibeChat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: _chatHistory.length,
                shrinkWrap: false,
                reverse: true,
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return ChatWidget(
                    chat: _chatHistory.reversed.elementAt(index),
                    shouldAnimate: _chatHistory.length - 1 == index &&
                        _chatHistory.reversed.elementAt(index)['isSender'] ==
                            false,
                  );
                },
              ),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                MaterialButton(
                  onPressed: () async {
                    XFile? result = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (result != null) {
                      setState(() {
                        _file = result.path;
                      });
                    }
                  },
                  minWidth: 42.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)),
                  padding: const EdgeInsets.all(0.0),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF69170),
                            Color(0xFF7D96E6),
                          ]),
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                    child: Container(
                        constraints: const BoxConstraints(
                            minWidth: 42.0, minHeight: 36.0),
                        alignment: Alignment.center,
                        child: Icon(
                          _file == null ? Icons.image : Icons.check,
                          color: Colors.white,
                        )),
                  ),
                ),
                const SizedBox(
                  width: 4.0,
                ),
                Expanded(
                  child: TextField(
                    focusNode: focusNode,
                    style: const TextStyle(color: Colors.white),
                    controller: _chatController,
                    decoration: const InputDecoration.collapsed(
                      hintText: "How can i help you?",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 4.0,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_chatController.text.isNotEmpty) {
                        if (_file != null) {
                          _chatHistory.add({
                            "time": DateTime.now(),
                            "message": _file,
                            "isSender": true,
                            "isImage": true
                          });
                        }

                        _chatHistory.add({
                          "time": DateTime.now(),
                          "message": _chatController.text,
                          "isSender": true,
                          "isImage": false
                        });
                      }
                    });

                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );

                    getAnswer(_chatController.text);
                    _chatController.clear();
                  },
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
