import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isPlaying = false;
  bool isCustomizingResponse = false;
  final TextEditingController _responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });
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
            onPressed: () {},
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
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.volume_up),
                    onPressed: () async {
                      if (isPlaying) {
                        await flutterTts.pause();
                        setState(() {
                          isPlaying = false;
                        });
                      } else {
                        await flutterTts.setLanguage('es-ES');
                        await flutterTts.setSpeechRate(0.5);
                        await flutterTts.speak('¿Lograste encontrar la lección que te di la última vez? Porque si no, puedo explicártela nuevamente con más detalles.');
                        setState(() {
                          isPlaying = true;
                        });
                      }
                    },
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
                            hintText: 'Escribe tu respuesta aquí...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onChanged: (text) {
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (_responseController.text.isEmpty)
                        IconButton(
                          icon: const Icon(Icons.mic, color: Color(0xFF607D8B)),
                          onPressed: () {
                            // Funcionalidad de dictado por voz
                          },
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF607D8B)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResponseDisplayScreen(response: _responseController.text),
                              ),
                            );
                          },
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
