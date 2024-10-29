// widgets/chat_message_widget.dart

import 'package:flutter/material.dart';
import 'chat_message.dart';

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final int index;
  final int? playingIndex;
  final Function(String, int) playText;

  const ChatMessageWidget({
    Key? key,
    required this.message,
    required this.index,
    required this.playingIndex,
    required this.playText,
  }) : super(key: key);

  BoxDecoration _getMessageDecoration(MessageType type) {
    switch (type) {
      case MessageType.system:
        return BoxDecoration(
          color: const Color(0xFFE8EAF6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case MessageType.user:
        return BoxDecoration(
          color: const Color(0xFF2D4554),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case MessageType.signLanguage:
        return BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF7B9DB0), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUserMessage = message.type == MessageType.user;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUserMessage && message.type == MessageType.signLanguage)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.sign_language, color: Color(0xFF7B9DB0)),
            ),
          if (!isUserMessage && message.type == MessageType.system)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.android, color: Color(0xFF2D4554)),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: _getMessageDecoration(message.type),
              child: Column(
                crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isUserMessage ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (!isUserMessage)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            playingIndex == index ? Icons.stop : Icons.volume_up,
                            color: const Color(0xFF1B455E),
                            size: 20,
                          ),
                          onPressed: () => playText(message.text, index),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
