import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quiputalk/utils/predefined_voices.dart';

class BackendService {
  // Uso de Singleton para BackendService
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  // Base URL del backend
  final String baseUrl = 'https://backendquipu.vercel.app'; // Cambia a tu IP local si estás en un dispositivo físico

  //final String localUrl = 'https://backendquipu.vercel.app';

  /// Método para probar la conexión con el backend
  Future<void> testBackendConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/hello_world/'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print('Backend Response: ${data['message']}');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error connecting to backend: $e');
    }
  }

  /// Método para iniciar una nueva sesión de conversación
  Future<String?> startSession() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/start_session/'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['session_id']; // Devolver el session_id
      } else {
        print('Error al iniciar sesión: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  /// Método para obtener sugerencias de respuesta
  Future<List<String>?> getSuggestReplies({
    required String userMessage,
    required String style,
    required String sessionId
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_suggested_replies/'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_message": userMessage,
          "style": style,
          "session_id": sessionId
        }),
      );

      // Ejemplo en el método getSuggestReplies del BackendService
      if (response.statusCode == 200) {
        Uint8List responseBytes = response.bodyBytes;
        String utf8Body = utf8.decode(responseBytes);
        var data = json.decode(utf8Body);
        String suggestedRepliesString = data['suggested_replies'];
        return suggestedRepliesString.split('\n').map((reply) => reply.trim()).toList();
      } else {
        print('Error al obtener sugerencias de respuesta: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error al obtener sugerencias de respuesta: $e');
      return null;
    }
  }

  Future<bool> sendUserResponse({
    required String userResponse,
    required String sessionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_user_response/'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_response": userResponse,
          "session_id": sessionId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error al enviar la respuesta del usuario: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error al enviar la respuesta del usuario: $e');
      return false;
    }
  }

  /// Envía rating y comentario al stub /send_feedback/
  Future<bool> sendFeedback({
    required String sessionId,
    required int rating,
    String comment = "",
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send_feedback/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': sessionId,
          'rating': rating,
          'comment': comment,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error en sendFeedback: $e');
      return false;
    }
  }

}
