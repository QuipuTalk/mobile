import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiputalk/providers/camera_controller_service.dart';
import 'package:quiputalk/screens/settings/settings_screen.dart';
import 'package:quiputalk/utils/hexadecimal_color.dart';

import '../../providers/conversation_service.dart';
import '../../providers/session_service.dart';
import '../../routes/conversation_navigator.dart';
import '../camera/camera_screen.dart';

// Importa tu FontSizeProvider
import 'package:quiputalk/providers/font_size_provider.dart';

class ResponseDisplayScreen extends StatelessWidget {
  final String response;
  final ConversationService _conversationService = ConversationService();

  ResponseDisplayScreen({Key? key, required this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el provider y calculamos factores
    final sessionService = Provider.of<SessionService>(context, listen: false);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    // Ejemplo: definimos tamaños base y calculamos un factor
    final double baseTitleSize = 20.0;
    final double baseBodySize = 18.0;
    final double factor = fontSizeProvider.fontSize / 16.0;

    // Ajustados con nuestro factor
    final double scaledTitleSize = baseTitleSize * factor;
    final double scaledBodySize = baseBodySize * factor;

    void _navigateToSettings() async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4554),
        title: Text(
          'Respuesta Personalizada',
          style: TextStyle(color: Colors.white, fontSize: scaledTitleSize),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Título "Respuesta"
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Respuesta',
                  // Quitamos el const porque usamos variables dinámicas
                  style: TextStyle(
                    fontSize: scaledTitleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Caja que muestra el texto de "response"
            Flexible(
              child: Card(
                color: HexColor.fromHex('E8F5FB'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      response,
                      style: TextStyle(fontSize: scaledBodySize),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Botones
            Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: ElevatedButton(
                    onPressed: () async {
                      await CameraControllerService.resetCamera();
                      await ConversationNavigator.navigateToCameraScreen(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB5050),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // Texto del botón escalable
                    child: Text(
                      'Volver a grabar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: scaledBodySize * 0.9, // si lo quieres un poco más chico
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      // Terminar la conversación y limpiar el sessionId
                      sessionService.clearSessionId();
                      _conversationService.clearMessages();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF607D8B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Terminar conversación',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: scaledBodySize * 0.9,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
