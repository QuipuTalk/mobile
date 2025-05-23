import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:quiputalk/utils/predefined_voices.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiputalk/screens/settings/settings_screen.dart';
import 'package:quiputalk/utils/hexadecimal_color.dart';
import 'package:quiputalk/screens/answer/response_display_screen.dart';
import 'package:quiputalk/widgets/chat_message.dart';
import 'package:quiputalk/widgets/chat_message_widget.dart';
import 'package:quiputalk/widgets/option_widget.dart';
import 'dart:developer';
import '../../providers/backend_service.dart';
import '../../providers/conversation_service.dart';
import '../../routes/conversation_navigator.dart';

class AnswerScreen extends StatefulWidget {
  final String initialMessage;
  final String sessionId;

  const AnswerScreen({
    Key? key,
    required this.initialMessage,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  //Services
  final ConversationService _conversationService = ConversationService();
  final BackendService _backendService = BackendService();

  //Controllers
  final ScrollController _scrollController = ScrollController();

  //TTS
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  //Variables
  int? playingIndex;
  bool isListening = false;
  bool isCustomizingResponse = false;
  String? selectedVoiceName;
  final TextEditingController _responseController = TextEditingController();

  List<String> suggestedReplies = []; // Estas son las que se muestran en la UI
  List<String> _originalSuggestedReplies = []; // Para guardar las originales antes de regenerar
  bool _areRepliesRegenerated = false; // True si suggestedReplies son regeneradas

  bool isLoadingReplies = false;
  String communicationStyle = 'neutral';
  bool isRecordingCancelled = false;

  // Voces predefinidas
  final Map<String, Map<String, String>> predefinedVoices = voices;

  @override
  void initState() {
    super.initState();
    _loadVoicePreference();
    _loadCommunicationStyle();
    flutterTts.setCompletionHandler(() => onTtsComplete());

    log("Session ID: ${widget.sessionId}");

    if (widget.initialMessage.isNotEmpty) {
      _addMessageAndGetInitialSuggestedReplies( // Cambiado para claridad y UH-30
        widget.initialMessage,
        MessageType.signLanguage,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadVoicePreference();
  }

  void _addMessage(String text, MessageType type) {
    _conversationService.addMessage(text, type);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  // Wrapper para la carga inicial de sugerencias (cuando llega un nuevo mensaje de señas)
  void _addMessageAndGetInitialSuggestedReplies(String text, MessageType type) {
    _addMessage(text, type);
    // Llama a fetch con isRegeneration: false para establecer nuevas originales
    _fetchSuggestedReplies(text, isRegeneration: false);
  }

  void _addMessageAndHandleUserResponse(String text, MessageType type) {
    _addMessage(text, type);
    _handleUserResponse(text);
    // Nota: Después de que el usuario envía una respuesta, si la IA responde y luego
    // el usuario ingresa otro mensaje de señas, se llamará a
    // _addMessageAndGetInitialSuggestedReplies, lo que reseteará _areRepliesRegenerated.
  }

  // Modificado para UH-30: renombrado y con parámetro isRegeneration
  Future<void> _fetchSuggestedReplies(String userMessage, {bool isRegeneration = false}) async {
    setState(() {
      isLoadingReplies = true;
      // Si NO es una regeneración, estamos obteniendo un conjunto fresco de sugerencias.
      // Reseteamos el estado de regeneración y las originales.
      if (!isRegeneration) {
        _areRepliesRegenerated = false;
        _originalSuggestedReplies = [];
      }
      // Si ES una regeneración, _areRepliesRegenerated ya fue puesto a true por el llamador,
      // y _originalSuggestedReplies ya contiene las originales de la tanda actual.
      // suggestedReplies = []; // Opcional: limpiar visualmente mientras carga
    });

    await _loadCommunicationStyle();

    List<String>? newReplies = await _backendService.getSuggestReplies(
      userMessage: userMessage,
      style: communicationStyle,
      sessionId: widget.sessionId,
    );

    if (mounted) { // Buena práctica
      setState(() {
        if (newReplies != null) {
          suggestedReplies = newReplies; // Actualizar las respuestas visibles
          if (!isRegeneration) {
            // Guardar estas como las "originales" para esta tanda
            _originalSuggestedReplies = List.from(newReplies);
          }
          // Si es regeneración, _originalSuggestedReplies no se toca.
        } else {
          // Manejar error, por ejemplo, limpiar sugerencias
          suggestedReplies = [];
          if (!isRegeneration) {
            _originalSuggestedReplies = [];
          }
        }
        isLoadingReplies = false;
      });
    }
  }

  // Para UH-30 Escenario 1: Confirmación de respuestas regeneradas
  void _confirmAndSendRegeneratedReply(String reply) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Envío'),
          content: Text('¿Deseas enviar la respuesta: "$reply"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enviar', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo
                _addMessageAndHandleUserResponse(reply, MessageType.user);
                ConversationNavigator.navigateToResponseDisplay(context, reply);
                // Nota: _areRepliesRegenerated sigue siendo true. Si el usuario quiere regenerar OTRA VEZ
                // antes de un nuevo mensaje de señas, se basará en las mismas _originalSuggestedReplies.
                // Se reseteará a false cuando llegue un nuevo mensaje de señas (_addMessageAndGetInitialSuggestedReplies).
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUserResponse(String responseText) async {
    // _conversationService.addMessage(responseText, MessageType.user); // Ya se añade en _addMessageAndHandleUserResponse

    bool success = await _backendService.sendUserResponse(
      userResponse: responseText,
      sessionId: widget.sessionId,
    );

    if (success) {
      // La navegación ya se hace en el onTap de OptionWidget y en _confirmAndSendRegeneratedReply
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ResponseDisplayScreen(response: responseText),
      //   ),
      // );
    } else {
      print("Error al enviar la respuesta del usuario al backend");
      // Considerar mostrar un SnackBar o mensaje de error al usuario
    }
  }

  Future<void> _loadCommunicationStyle() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      communicationStyle = prefs.getString('communication_style') ?? 'neutral';
    });
  }

  void onTtsComplete() {
    setState(() {
      playingIndex = null;
    });
  }

  Future<void> _loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedVoiceName = prefs.getString('voice_name') ?? 'es-es-x-eef-local';
    });
  }

  void _navigateToSettings() async {
    flutterTts.stop();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    await _loadVoicePreference();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _playText(String text, int index) async {
    if (playingIndex == index) {
      await flutterTts.stop();
      setState(() {
        playingIndex = null;
      });
      return;
    }
    try {
      String locale =
          predefinedVoices[selectedVoiceName]?['locale'] ?? 'es-ES';
      await flutterTts.setLanguage(locale);
      await flutterTts.setVoice({
        'name': selectedVoiceName!,
        'locale': locale,
      });
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setPitch(1.0);
      await flutterTts.setVolume(1.0);
      setState(() {
        playingIndex = index;
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
        title: const Text(
          'Conversación',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF2D4554),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
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
                  controller: _scrollController,
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
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Mensaje',
                        hintStyle: const TextStyle(color: Color(0xFFD9D9D9)),
                        filled: true,
                        fillColor: const Color(0xD92D4554),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF7A8892),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _responseController.text.isEmpty
                          ? Icon(
                        isListening ? Icons.mic_off : Icons.mic,
                        color: const Color(0xFFFFFFFF),
                      )
                          : const Icon(Icons.send, color: Color(0xFFFFFFFF)),
                      onPressed: _responseController.text.isEmpty
                          ? _listen
                          : () {
                        if (_responseController.text.isNotEmpty) {
                          setState(() {
                            String responseText = _responseController.text;
                            _addMessageAndHandleUserResponse( // Modificado para usar la función centralizada
                              responseText,
                              MessageType.user,
                            );
                            _responseController.clear();
                            isCustomizingResponse = false;

                            ConversationNavigator.navigateToResponseDisplay( // Asegurar navegación
                              context,
                              responseText,
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
                      Icon( // Considerar cambiar este ícono o su lógica si es necesario
                        Icons.sync, // Este ícono podría ser confuso ahora
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
                    constraints: const BoxConstraints(
                      maxHeight: 250, // Ajusta según sea necesario con los nuevos botones
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Opciones',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (isLoadingReplies)
                            const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          else
                            for (var reply in suggestedReplies) ...[
                              OptionWidget(
                                text: reply,
                                onTap: () {
                                  // UH-30 Condición para confirmación
                                  if (_areRepliesRegenerated) {
                                    _confirmAndSendRegeneratedReply(reply);
                                  } else {
                                    // Comportamiento original para respuestas no regeneradas
                                    _addMessageAndHandleUserResponse(
                                      reply,
                                      MessageType.user,
                                    );
                                    ConversationNavigator.navigateToResponseDisplay(
                                      context,
                                      reply,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                            ],

                          // Botón "Volver a generar"
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                final lastSignLanguageMsg = _conversationService.messages.lastWhere(
                                      (msg) => msg.type == MessageType.signLanguage,
                                  orElse: () => ChatMessage(widget.initialMessage, MessageType.signLanguage), // Fallback
                                );
                                // UH-30: Marcar que estamos a punto de regenerar
                                setState(() {
                                  _areRepliesRegenerated = true;
                                });
                                _fetchSuggestedReplies(lastSignLanguageMsg.text, isRegeneration: true);
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
                          const SizedBox(height: 8), // Espacio antes del nuevo botón

                          // UH-30 Escenario 2: Botón para revertir a originales
                          if (_areRepliesRegenerated) ...[
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    suggestedReplies = List.from(_originalSuggestedReplies);
                                    _areRepliesRegenerated = false; // Ya no son regeneradas
                                  });
                                },
                                child: const Text(
                                  'Usar respuestas originales',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    color: Color(0xFFE0E0E0), // Un color diferente, ej. blanco más claro o un acento
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12), // Espacio después del nuevo botón
                          ]
                        ],
                      ),
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
                          child: const Text(
                            'Volver a grabar',
                            style: TextStyle(color: Colors.white),
                          ),
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
                          child: const Text(
                            'Personalizar respuesta',
                            style: TextStyle(color: Colors.white),
                          ),
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
        setState(() {
          isListening = true;
          isRecordingCancelled = false;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text(
                    "Escuchando...",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: _responseController,
                    builder: (context, value, child) {
                      return Text(
                        _responseController.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isListening = false;
                    });
                    _speech.stop();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Aceptar",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isListening = false;
                      isRecordingCancelled = true;
                      _responseController.clear();
                    });
                    _speech.stop();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );

        _speech.listen(
          localeId: 'es_ES',
          onResult: (val) => setState(() {
            if (!isRecordingCancelled) {
              _responseController.text = val.recognizedWords;
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