import 'package:flutter/material.dart';
import 'package:quiputalk/widgets/chat_message.dart';

import '../providers/conversation_service.dart';
import '../screens/answer/answer_screen.dart';
import '../screens/answer/response_display_screen.dart';
import '../screens/camera/camera_screen.dart';
import '../screens/camera/video_screen.dart';

class ConversationNavigator {
  static final ConversationService _conversationService = ConversationService();

  static Future<void> startNewRecording(BuildContext context) async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
          (route) => false,
    );
  }

  static Future<void> navigateToVideo(BuildContext context, String videoPath) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoScreen(videoPath: videoPath)),
    );
  }

  static Future<void> navigateToAnswer(BuildContext context, String translatedMessage) async {
    // Añadir el mensaje traducido al servicio
    _conversationService.addMessage(translatedMessage, MessageType.signLanguage);

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AnswerScreen()),
    );
  }

  static Future<void> navigateToResponseDisplay(BuildContext context, String response) async {
    // Añadir la respuesta del usuario al servicio
    _conversationService.addMessage(response, MessageType.user);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResponseDisplayScreen(response: response),
      ),
    );
  }
}