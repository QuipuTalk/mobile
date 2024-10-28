import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiputalk/utils/rounded_card.dart';
import 'package:flutter_tts/flutter_tts.dart';

// voice_settings_screen.dart

class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String? selectedVoiceName;
  bool isPlaying = false;
  bool isLoading = true;

  final List<Map<String, dynamic>> predefinedVoices = [
    {
      'name': 'es-es-x-eef-local',
      'locale': 'es-ES',
      'label': 'Masculina',
    },
    {
      'name': 'es-us-x-sfb-network',
      'locale': 'es-US',
      'label': 'Femenina',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    flutterTts.setCompletionHandler(() => setState(() => isPlaying = false));
  }

  Future<void> _initializeTts() async {
    await _loadVoicePreference();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadVoicePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedVoice = prefs.getString('voice_name');

    if (savedVoice != null && predefinedVoices.any((voice) => voice['name'] == savedVoice)) {
      setState(() {
        selectedVoiceName = savedVoice;
      });
    } else {
      setState(() {
        selectedVoiceName = predefinedVoices[0]['name'];
      });
    }
  }

  Future<void> _saveVoicePreference() async {
    if (selectedVoiceName != null) {
      final prefs = await SharedPreferences.getInstance();
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
      var selectedVoice = predefinedVoices.firstWhere((voice) => voice['name'] == selectedVoiceName);

      await flutterTts.setLanguage(selectedVoice['locale']);
      await flutterTts.setVoice({
        'name': selectedVoice['name'],
        'locale': selectedVoice['locale'],
      });

      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setPitch(1.0);
      await flutterTts.setVolume(1.0);

      setState(() => isPlaying = true);
      String voiceLabel = selectedVoice['label'];
      await flutterTts.speak('Este es un ejemplo de la voz $voiceLabel');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF49A5DE),
              Color(0xFF2D4554),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back button
              Positioned(
                left: 16,
                top: 16,
                child: IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              // Title
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    'Ajustes de Voz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Main Card - Modified position and height
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: size.height * 0.85, // Increased from 0.7 to 0.85
                child: RoundedCard(
                  height: size.height * 0.85,
                  radius: size.width * 0.1,
                  child: Column(
                    children: [
                      // Added spacer at the top
                      SizedBox(height: size.height * 0.05),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.08,
                            vertical: size.height * 0.02,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Selecciona el tipo de voz',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              const SizedBox(height: 20),
                              DropdownButton<String>(
                                value: selectedVoiceName,
                                items: predefinedVoices.map((voice) {
                                  return DropdownMenuItem<String>(
                                    value: voice['name'],
                                    child: Text(voice['label']),
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
                                icon: Icon(
                                    isPlaying ? Icons.stop : Icons.play_arrow
                                ),
                                label: Text(
                                    isPlaying ? 'Detener' : 'Probar Voz'
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
