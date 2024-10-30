// conversation_service.dart

import 'package:flutter/material.dart';
import 'package:quiputalk/widgets/chat_message.dart';

class ConversationService extends ChangeNotifier {
  static final ConversationService _instance = ConversationService._internal();

  factory ConversationService() {
    return _instance;
  }

  ConversationService._internal();

  List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void addMessage(String text, MessageType type) {
    _messages.add(ChatMessage(text, type));
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}