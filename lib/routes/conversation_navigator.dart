import 'package:flutter/material.dart';
import 'package:quiputalk/widgets/chat_message.dart';

import '../providers/camera_controller_service.dart';
import '../providers/conversation_service.dart';
import '../screens/answer/answer_screen.dart';
import '../screens/answer/response_display_screen.dart';
import '../screens/camera/camera_screen.dart';
import '../screens/camera/video_screen.dart';

class ConversationNavigator {
  static final ConversationService _conversationService = ConversationService();

  static Future<void> startNewRecording(BuildContext context) async {
    await CameraControllerService.resetCamera();
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
        settings: const RouteSettings(name: 'CameraScreen'),
      ),
          (route) => false,
    );
  }

  static Future<void> navigateToVideo(BuildContext context, String videoPath) async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VideoScreen(videoPath: videoPath),
        settings: const RouteSettings(name: 'VideoScreen'),
      ),
    );
  }

  static Future<void> navigateToCameraScreen(BuildContext context) async {
    await CameraControllerService.resetCamera();
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
        settings: const RouteSettings(name: 'CameraScreen'),
      ),
    );
  }

/*  static Future<void> navigateToAnswer(BuildContext context, String translatedMessage) async {
    _conversationService.addMessage(translatedMessage, MessageType.signLanguage);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnswerScreen(initialMessage: 'Hola que hace', sessionId: '',),
        settings: const RouteSettings(name: 'AnswerScreen'),
      ),
    );
  }*/

/*  static Future<void> navigateToResponseDisplay(BuildContext context, String response) async {
    // Añadir la respuesta del usuario al servicio
    _conversationService.addMessage(response, MessageType.user);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResponseDisplayScreen(response: response),
      ),
    );
  }*/
  static Future<void> navigateToResponseDisplay(BuildContext context, String response) async {
    _conversationService.addMessage(response, MessageType.user);
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResponseDisplayScreen(response: response),
        settings: const RouteSettings(name: 'ResponseScreen'),
      ),
    );
  }

}