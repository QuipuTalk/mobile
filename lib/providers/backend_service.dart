import 'package:http/http.dart' as http;
import 'dart:convert';

class BackendService {
  // Uso de Singleton para BackendService
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  // Base URL del backend
  final String baseUrl = 'http://10.0.2.2:8000'; // Cambia a tu IP local si estás en un dispositivo físico

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
}
