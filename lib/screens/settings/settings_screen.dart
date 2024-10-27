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
  List<Map<String, dynamic>> predefinedVoices = [
    {
      'name': 'es-es-x-eef-local',
      'locale': 'es-ES',
      'label': 'Masculina',
      'gender': 'male'
    },
    {
      'name': 'es-us-x-sfb-network',
      'locale': 'es-US',
      'label': 'Femenina',
      'gender': 'female'
    },
  ];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initTts();
    flutterTts.setCompletionHandler(() => setState(() => isPlaying = false));
  }

  Future<void> _initTts() async {
    await _loadVoicePreference();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedVoice = prefs.getString('voice_name');

    if (savedVoice != null) {
      bool voiceExists = predefinedVoices.any((voice) => voice['name'] == savedVoice);
      if (voiceExists) {
        setState(() {
          selectedVoiceName = savedVoice;
        });
      }
    } else {
      // Si no hay voz guardada, usar la masculina por defecto
      setState(() {
        selectedVoiceName = predefinedVoices[0]['name'];
      });
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
        var selectedVoice = predefinedVoices.firstWhere(
              (voice) => voice['name'] == selectedVoiceName,
        );

        await flutterTts.setLanguage(selectedVoice['locale']);
        await flutterTts.setVoice({
          'name': selectedVoice['name'],
          'locale': selectedVoice['locale'],
        });

        await flutterTts.setSpeechRate(0.5);
        await flutterTts.setPitch(1.0);
        await flutterTts.setVolume(1.0);

        setState(() => isPlaying = true);
        String voiceType = selectedVoice['label'];
        await flutterTts.speak('Este es un ejemplo de la voz $voiceType');
      } catch (e) {
        print("Error al configurar o reproducir la voz: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de Voz'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selecciona el tipo de voz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedVoiceName,
              items: predefinedVoices.map((voice) {
                return DropdownMenuItem<String>(
                  value: voice['name'] as String,
                  child: Text(voice['label'] as String),
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
            ElevatedButton.icon(
              onPressed: _playTestVoice,
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(isPlaying ? 'Detener' : 'Probar Voz'),
            ),
          ],
        ),
      ),
    );
  }
}