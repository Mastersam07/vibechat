import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'constants/constants.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    required Map<String, dynamic> chat,
    required bool shouldAnimate,
  })  : _chat = chat,
        _shouldAnimate = shouldAnimate;

  final Map<String, dynamic> _chat;
  final bool _shouldAnimate;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _chat["isSender"] == true ? scaffoldBackgroundColor : cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _chat["isSender"] == true
                  ? Icons.person
                  : Icons.chat_bubble_outline,
              size: 30,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: _chat["isSender"] == true
                  ? _chat["isImage"]
                      ? Image.file(File(_chat["message"]), width: 200)
                      : Text(
                          _chat["message"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                  : _shouldAnimate
                      ? DefaultTextStyle(
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                          child: AnimatedTextKit(
                              isRepeatingAnimation: false,
                              repeatForever: false,
                              displayFullTextOnTap: true,
                              totalRepeatCount: 1,
                              animatedTexts: [
                                TyperAnimatedText(
                                  _chat["message"],
                                ),
                              ]),
                        )
                      : Text(
                          _chat["message"],
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
            ),
            _chat["isSender"] == 0
                ? const SizedBox.shrink()
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.thumb_up_alt_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.thumb_down_alt_outlined,
                        color: Colors.white,
                      )
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
