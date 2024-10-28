import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiputalk/screens/settings/settings_screen.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}



class _AnswerScreenState extends State<AnswerScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool isPlaying = false;
  bool isCustomizingResponse = false;
  bool isListening = false;
  String? selectedVoiceName;
  final TextEditingController _responseController = TextEditingController();

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Traducción:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
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
                  const Expanded(
                    child: Text(
                      '¿Lograste encontrar la lección que te di la última vez? Porque si no, puedo explicártela nuevamente con más detalles.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x7A8892),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.volume_up, color: const Color(
                          0xFF1B455E)),
                      onPressed: () => _playText(
                        '¿Lograste encontrar la lección que te di la última vez? Porque si no, puedo explicártela nuevamente con más detalles.',
                      ),

                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!isCustomizingResponse) ...[
              Row(
                children: [
                  const Text(
                    'Elige una respuesta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.sync,
                    color: Colors.grey[700],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFB0BEC5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildOption('Sí, encontré la lección, pero me costó entender algunos puntos. ¿Podrías aclararlos?'),
                    const SizedBox(height: 10),
                    _buildOption('No, no pude encontrarla. ¿Podrías explicármela de nuevo, por favor?'),
                    const SizedBox(height: 10),
                    _buildOption('Sí, la encontré y la revisé, pero me gustaría que me expliques algunos detalles adicionales.'),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB5050),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Volver a grabar', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isCustomizingResponse = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF607D8B),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Personalizar respuesta', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ] else ...[
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _responseController,
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
                      if (_responseController.text.isEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A8892),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(isListening ? Icons.mic_off : Icons.mic, color: const Color(0xFFFFFFFF)),
                            onPressed: _listen,
                          ),
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A8892),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Color(0xFFFFFFFF)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResponseDisplayScreen(response: _responseController.text),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String text) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
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
        style: const TextStyle(fontSize: 16),
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

class ResponseDisplayScreen extends StatelessWidget {
  final String response;

  const ResponseDisplayScreen({Key? key, required this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4554),
        title: const Text('Respuesta Personalizada'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              response,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB5050),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Volver a grabar', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF607D8B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Terminar conversación', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}