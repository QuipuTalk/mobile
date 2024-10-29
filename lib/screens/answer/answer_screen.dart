import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiputalk/screens/settings/settings_screen.dart';
import 'package:quiputalk/utils/hexadecimal_color.dart';
import 'package:quiputalk/screens/answer/response_display_screen.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isPlaying = false;
  bool isListening = false;
  bool isCustomizingResponse = false;
  String? selectedVoiceName;
  final TextEditingController _responseController = TextEditingController();
  List<String> messages = [
    '¿Lograste encontrar la lección que te di la última vez? Porque si no, puedo explicártela nuevamente con más detalles.'
  ];

  // Definimos las voces predefinidas
  final Map<String, Map<String, String>> predefinedVoices = {
    'es-es-x-eef-local': {'locale': 'es-ES', 'label': 'Masculina'},
    'es-us-x-sfb-network': {'locale': 'es-US', 'label': 'Femenina'},
  };

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
      isPlaying = false;
    });
  }

  Future<void> _playText(String text) async {
    if (isPlaying) {
      await flutterTts.stop();
      setState(() {
        isPlaying = false;
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
        isPlaying = true;
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          messages[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.volume_up,
                          color: const Color(0xFF1B455E),
                        ),
                        onPressed: () => _playText(messages[index]),
                      ),
                    ],
                  ),
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
                            messages.add(_responseController.text);
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
                        _buildOption('Sí, encontré la lección, pero me costó entender algunos puntos. ¿Podrías aclararlos?'),
                        const SizedBox(height: 8),
                        _buildOption('No, no pude encontrarla. ¿Podrías explicármela de nuevo, por favor?'),
                        const SizedBox(height: 8),
                        _buildOption('Sí, la encontré y la revisé, pero me gustaría que me expliques algunos detalles adicionales.'),
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
                          onPressed: () {},
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

  Widget _buildOption(String text) {
    return GestureDetector(
      onTap: () {
        setState(() {
          messages.add(text);
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResponseDisplayScreen(response: text),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: HexColor.fromHex('#617D8C'),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
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


