import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String? selectedVoiceName;
  bool isPlaying = false;
  List<dynamic> spanishVoices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    flutterTts.setCompletionHandler(() => setState(() => isPlaying = false));
  }

  Future<void> _initTts() async {
    await _getSpanishVoices();
    await _loadVoicePreference();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getSpanishVoices() async {
    try {
      var voices = await flutterTts.getVoices;

      setState(() {
        spanishVoices = voices.where((voice) {
          return (voice['locale'] as String).startsWith('es-');
        }).toList();

        // Solo establecer una voz por defecto si no hay ninguna seleccionada
        if (spanishVoices.isNotEmpty && selectedVoiceName == null) {
          selectedVoiceName = spanishVoices.first['name'];
        }
      });

      print('Voces encontradas: ${spanishVoices.length}');
      for (var voice in spanishVoices) {
        print('Nombre: ${voice['name']}, Locale: ${voice['locale']}');
      }
    } catch (e) {
      print('Error al obtener las voces: $e');
    }
  }

  Future<void> _loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedVoice = prefs.getString('voice_name');

    if (savedVoice != null) {
      bool voiceExists = spanishVoices.any((voice) => voice['name'] == savedVoice);
      if (voiceExists) {
        setState(() {
          selectedVoiceName = savedVoice;
        });
      }
    }
  }

  Future<void> _saveVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (selectedVoiceName != null) {
      await prefs.setString('voice_name', selectedVoiceName!);
    }
  }

  Future<void> _playTestVoice() async {
    if (isPlaying) {
      await flutterTts.stop();
      setState(() => isPlaying = false);
      return;
    }

    if (selectedVoiceName != null) {
      try {
        // Encontrar la voz seleccionada y su locale
        var selectedVoice = spanishVoices.firstWhere(
              (voice) => voice['name'] == selectedVoiceName,
          orElse: () => null,
        );

        if (selectedVoice != null) {
          // Configurar el idioma específico de la voz
          await flutterTts.setLanguage(selectedVoice['locale']);

          // Configurar la voz específica
          await flutterTts.setVoice({
            'name': selectedVoiceName!,
            'locale': selectedVoice['locale'],
          });

          // Configurar otros parámetros
          await flutterTts.setSpeechRate(0.5);
          await flutterTts.setPitch(1.0);
          await flutterTts.setVolume(1.0);

          setState(() => isPlaying = true);
          await flutterTts.speak('Este es un ejemplo de la voz $selectedVoiceName');
        }
      } catch (e) {
        print("Error al configurar o reproducir la voz: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (spanishVoices.isEmpty)
              const Text('No se encontraron voces en español'),
            if (spanishVoices.isNotEmpty) ...[
              DropdownButton<String>(
                value: selectedVoiceName,
                items: spanishVoices.map((voice) {
                  return DropdownMenuItem<String>(
                    value: voice['name'] as String,
                    child: Text('${voice['name']} (${voice['locale']})'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedVoiceName = newValue;
                    _saveVoicePreference();
                    _playTestVoice();
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _playTestVoice,
                child: Text(isPlaying ? 'Detener' : 'Probar Voz'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}