import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiputalk/screens/settings/settings_screen.dart';
import 'package:quiputalk/utils/hexadecimal_color.dart';
import 'package:quiputalk/screens/answer/response_display_screen.dart';
import 'package:quiputalk/widgets/chat_message.dart';
import 'package:quiputalk/widgets/chat_message_widget.dart';
import 'package:quiputalk/widgets/option_widget.dart';

import '../../providers/conversation_service.dart';
import '../../routes/conversation_navigator.dart';


class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {

  final ConversationService _conversationService = ConversationService();

  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  int? playingIndex; // Almacena el índice del mensaje que está siendo reproducido actualmente
  bool isListening = false;
  bool isCustomizingResponse = false;
  String? selectedVoiceName;
  final TextEditingController _responseController = TextEditingController();
  // Definimos las voces predefinidas
  final Map<String, Map<String, String>> predefinedVoices = {
    'es-es-x-eef-local': {'locale': 'es-ES', 'label': 'Masculina'},
    'es-us-x-sfb-network': {'locale': 'es-US', 'label': 'Femenina'},
  };

/*  List<String> messages = [
    '¿Lograste encontrar la lección que te di la última vez? Porque si no, puedo explicártela nuevamente con más detalles.'
  ];*/

  List<ChatMessage> messages = [
    ChatMessage(
        '¿Lograste encontrar la lección que te di la última vez? Porque si no, puedo explicártela nuevamente con más detalles.',
        MessageType.signLanguage
    )
  ];

// 2. Modifica el método _addMessage para manejar ChatMessage:
  void _addMessage(String text, MessageType type) {
    _conversationService.addMessage(text, type);
  }


  @override
  void initState() {
    super.initState();
    _loadVoicePreference();
    flutterTts.setCompletionHandler(() => onTtsComplete());
  }

  void _navigateToSettings() async {
    flutterTts.stop();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    await _loadVoicePreference(); // Recargar la preferencia después de regresar
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadVoicePreference(); // Recargar preferencias si las dependencias cambian
  }

  @override
  void dispose() {
    flutterTts.stop(); // Detener el TTS cuando la pantalla se destruya
    super.dispose();
  }

  Future<void> _loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Si no hay preferencia guardada, usa la voz masculina por defecto
      selectedVoiceName = prefs.getString('voice_name') ?? 'es-es-x-eef-local';
    });
  }

  void onTtsComplete() {
    setState(() {
      playingIndex = null;
    });
  }

  Future<void> _playText(String text, int index) async {
    if (playingIndex == index) {
      // Si el índice del mensaje es el mismo, detén la reproducción
      await flutterTts.stop();
      setState(() {
        playingIndex = null; // No hay ningún mensaje reproduciéndose
      });
      return;
    }

    try {
      // Configurar la voz según la preferencia guardada
      String locale = predefinedVoices[selectedVoiceName]?['locale'] ?? 'es-ES';

      await flutterTts.setLanguage(locale);
      await flutterTts.setVoice({
        'name': selectedVoiceName!,
        'locale': locale,
      });

      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setPitch(1.0);
      await flutterTts.setVolume(1.0);

      setState(() {
        playingIndex = index; // Actualiza el índice del mensaje que se está reproduciendo
      });

      await flutterTts.speak(text);
    } catch (e) {
      print("Error al reproducir el texto: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversación',style: TextStyle(color: Colors.white),),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF2D4554),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              // Navegar a la pantalla de ajustes y recargar la preferencia al volver
              _navigateToSettings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListenableBuilder(
              listenable: _conversationService,
              builder: (context, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _conversationService.messages.length,
                  itemBuilder: (context, index) {
                    return ChatMessageWidget(
                      message: _conversationService.messages[index],
                      index: index,
                      playingIndex: playingIndex,
                      playText: _playText,
                    );
                  },
                );
              },
            ),
          ),
          if (isCustomizingResponse)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _responseController,
                      maxLines: 5, // Permite que el TextField se expanda en líneas.
                      minLines: 1, // Establece el mínimo número de líneas.
                      decoration: InputDecoration(
                        hintText: 'Mensaje',
                        hintStyle: const TextStyle(color: Color(0xFFD9D9D9)),
                        filled: true,
                        fillColor: const Color(0xD92D4554),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A8892),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _responseController.text.isEmpty
                          ? Icon(isListening ? Icons.mic_off : Icons.mic, color: const Color(0xFFFFFFFF))
                          : const Icon(Icons.send, color: Color(0xFFFFFFFF)),
                      onPressed: _responseController.text.isEmpty
                          ? _listen
                          : () {
                        if (_responseController.text.isNotEmpty) {
                          setState(() {
                            _addMessage(_responseController.text, MessageType.user);
                            String responseText = _responseController.text;
                            _responseController.clear();
                            isCustomizingResponse = false;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResponseDisplayScreen(response: responseText),
                              ),
                            );

                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (!isCustomizingResponse)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Elige una respuesta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.sync,
                        color: Colors.grey[700],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: HexColor.fromHex('#7B9DB0'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Opciones',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        const SizedBox(height: 8),
                        OptionWidget(
                          text: 'Sí, encontré la lección, pero me costó entender algunos puntos. ¿Podrías aclararlos?',
                          onTap: () {
                            String response = 'Sí, encontré la lección, pero me costó entender algunos puntos. ¿Podrías aclararlos?';
                            _conversationService.addMessage(response, MessageType.user);
                            ConversationNavigator.navigateToResponseDisplay(context, response);
                          },
                        ),
                        const SizedBox(height: 8),
                        OptionWidget(
                          text: 'No, no pude encontrarla. ¿Podrías explicármela de nuevo, por favor?',
                          onTap: () {
                            String response = 'No, no pude encontrarla. ¿Podrías explicármela de nuevo, por favor?';
                            _conversationService.addMessage(response, MessageType.user);
                            ConversationNavigator.navigateToResponseDisplay(context, response);
                          },
                        ),
                        const SizedBox(height: 8),
                        OptionWidget(
                          text: 'Sí, la encontré y la revisé, pero me gustaría que me expliques algunos detalles adicionales.',
                          onTap: () {
                            String response = 'Sí, la encontré y la revisé, pero me gustaría que me expliques algunos detalles adicionales.';
                            _conversationService.addMessage(response, MessageType.user);
                            ConversationNavigator.navigateToResponseDisplay(context, response);
                          },
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              // Acción para "Volver a generar"
                            },
                            child: const Text(
                              'Volver a generar',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ConversationNavigator.startNewRecording(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDB5050),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Volver a grabar', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isCustomizingResponse = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF607D8B),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Personalizar respuesta',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _listen() async {
    if (!isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => setState(() {
          if (val == "done") {
            isListening = false;
          }
        }),
        onError: (val) => setState(() {
          isListening = false;
        }),
      );
      if (available) {
        setState(() => isListening = true);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text("Escuchando...", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                ValueListenableBuilder(
                  valueListenable: _responseController,
                  builder: (context, value, child) {
                    return Text(
                      _responseController.text,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            ),
          ),
        );
        _speech.listen(
          localeId: 'es_ES',
          onResult: (val) => setState(() {
            _responseController.text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              Navigator.of(context).pop();
            }
          }),
        );
      }
    } else {
      setState(() => isListening = false);
      _speech.stop();
    }
  }
}


