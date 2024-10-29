// widgets/chat_message.dart

enum MessageType {
  system,
  user,
  signLanguage,
}

class ChatMessage {
  final String text;
  final MessageType type;

  ChatMessage(this.text, this.type);
}
