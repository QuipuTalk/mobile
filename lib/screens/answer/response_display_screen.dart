import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiputalk/providers/camera_controller_service.dart';
import 'package:quiputalk/screens/settings/settings_screen.dart';
import 'package:quiputalk/utils/hexadecimal_color.dart';
import 'package:quiputalk/providers/backend_service.dart';
import '../../providers/conversation_service.dart';
import '../../providers/session_service.dart';
import '../../routes/conversation_navigator.dart';
import '../camera/camera_screen.dart';

// Importa tu FontSizeProvider
import 'package:quiputalk/providers/font_size_provider.dart';

class ResponseDisplayScreen extends StatefulWidget {
  final String response;

  const ResponseDisplayScreen({Key? key, required this.response}) : super(key: key);

  @override
  State<ResponseDisplayScreen> createState() => _ResponseDisplayScreenState();
}

class _ResponseDisplayScreenState extends State<ResponseDisplayScreen> {
  final ConversationService _conversationService = ConversationService();

  // Variables para rating (estrellas) y comentario
  int _selectedStars = 0;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sessionService = Provider.of<SessionService>(context, listen: false);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    // Ajustamos tamaños según el slider de accesibilidad
    final double baseTitleSize = 20.0;
    final double baseBodySize = 18.0;
    final double factor = fontSizeProvider.fontSize / 16.0;

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
                      widget.response,
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
                // Botón "Volver a grabar"
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
                    child: Text(
                      'Volver a grabar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: scaledBodySize * 0.9,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Botón "Terminar conversación"
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      // En lugar de terminar la conversación de inmediato,
                      // mostramos el diálogo de calificación
                      _showRatingDialog(sessionService);
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

  /// Muestra el diálogo de calificación
  void _showRatingDialog(SessionService sessionService) {
    showDialog(
      context: context,
      barrierDismissible: false, // usuario debe elegir algo
      builder: (BuildContext dialogContext) {
        // Usamos un StatefulBuilder para refrescar el estado de estrellas
        return StatefulBuilder(
          builder: (BuildContext localCtx, StateSetter setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('¿Cómo calificarías tu experiencia con QuipuTalk?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filita de estrellas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        icon: Icon(
                          starIndex <= _selectedStars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          // Actualizamos el estado del diálogo
                          setStateDialog(() {
                            _selectedStars = starIndex;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  // Comentario opcional
                  TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Comparte un comentario (opcional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Cierra el diálogo de calificación
                    Navigator.of(dialogContext).pop();
                    // Fin de la conversación
                    _endConversation(sessionService);
                  },
                  child: const Text('Omitir'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Obtenemos el BackendService AQUÍ dentro del onPressed
                    final backendService = BackendService(); // <-- Cambio aquí

                    // Ejemplo: imprimir la calificación
                    print('Estrellas seleccionadas: $_selectedStars');
                    print('Feedback: ${_feedbackController.text}');

                    // Enviar feedback al backend
                    try {
                      bool ok = await backendService.sendFeedback(
                        sessionId: sessionService.sessionId!,
                        rating: _selectedStars,
                        comment: _feedbackController.text.trim(),
                      );
                      if (!ok) print('Warning: feedback no guardado en backend.');
                    } catch (e) {
                      print('Error enviando feedback: $e');
                    }

                    // 1. Cerrar diálogo de calificación
                    Navigator.of(dialogContext).pop();

                    // 2. Muestra diálogo "Gracias por calificar"
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext thanksDialogCtx) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Gracias por calificar tu experiencia',
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(height: 16),
                              Icon(Icons.sign_language, size: 48, color: Colors.blueGrey),
                            ],
                          ),
                        );
                      },
                    );

                    // 3. Espera 2s
                    await Future.delayed(const Duration(seconds: 2));

                    // 4. Cierra el popUp "Gracias" y termina la conversación (si sigue montado)
                    if (!mounted) return;
                    Navigator.of(context).pop();

                    if (!mounted) return;
                    _endConversation(sessionService);
                  },
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Finaliza la conversación y regresa a la pantalla principal
  void _endConversation(SessionService sessionService) {
    sessionService.clearSessionId();
    _conversationService.clearMessages();
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}