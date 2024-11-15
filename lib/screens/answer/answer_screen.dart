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
  List<String> suggestedReplies = [];
  bool isLoadingReplies = false;
  String communicationStyle = 'neutral';


  // We call voices
  final Map<String, Map<String, String>> predefinedVoices = voices;


  @override
  void initState() {
    super.initState();
    _loadVoicePreference();
    _loadCommunicationStyle();
    flutterTts.setCompletionHandler(() => onTtsComplete());

    // Log para verificar si sessionId se pasó correctamente
    log("Session ID: ${widget.sessionId}");

    // Agregar el mensaje inicial al historial de mensajes
    if (widget.initialMessage.isNotEmpty) {
      _addMessageAndGetSuggestedReplies(widget.initialMessage, MessageType.signLanguage);
    }

    // Programa el scroll al final después de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    flutterTts.stop(); // Detener el TTS cuando la pantalla se destruya
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadVoicePreference(); // Recargar preferencias si las dependencias cambian
  }

  void _addMessage(String text, MessageType type) {
    _conversationService.addMessage(text, type);
    // Programa el scroll al final después de que se actualice el estado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _addMessageAndGetSuggestedReplies(String text, MessageType type) {
    _addMessage(text, type);
    _getSuggestedReplies(text);
  }

  void _addMessageAndHandleUserResponse(String text, MessageType type){
    _addMessage(text, type);
    _handleUserResponse(text);
  }

  Future<void> _getSuggestedReplies(String userMessage) async {

    setState(() {
      isLoadingReplies=true;
    });

    await _loadCommunicationStyle(); // Asegurarse de tener el estilo de comunicación actualizado

    List<String>? replies = await _backendService.getSuggestReplies(
      userMessage: userMessage,
      style: communicationStyle,
      sessionId: widget.sessionId,
    );

    if (replies != null) {
      setState(() {
        suggestedReplies = replies;
        isLoadingReplies=false;
      });
    } else {
        isLoadingReplies = false; //ocultar indicador si hay un error
    }
  }

  void _handleUserResponse(String responseText) async {
    _conversationService.addMessage(responseText, MessageType.user);

    // Enviar la respuesta del usuario al backend
    bool success = await _backendService.sendUserResponse(
      userResponse: responseText,
      sessionId: widget.sessionId,
    );

    if (success) {
      // Navegar a la siguiente pantalla o actualizar la UI según sea necesario
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResponseDisplayScreen(response: responseText),
        ),
      );
    } else {
      // Manejar el error según sea necesario
      print("Error al enviar la respuesta del usuario al backend");
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
      // Si no hay preferencia guardada, usa la voz masculina por defecto
      selectedVoiceName = prefs.getString('voice_name') ?? 'es-es-x-eef-local';
    });
  }

  void _navigateToSettings() async {
    flutterTts.stop();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    await _loadVoicePreference(); // Recargar la preferencia después de regresar
  }

  // Método para hacer scroll hasta el final
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

                            String responseText = _responseController.text;
                            _addMessageAndHandleUserResponse(responseText, MessageType.user);
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
                        if(isLoadingReplies)
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
                                _addMessageAndHandleUserResponse(reply, MessageType.user);
                                ConversationNavigator.navigateToResponseDisplay(context, reply);
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
/*                        Center(
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
                        ),*/
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


