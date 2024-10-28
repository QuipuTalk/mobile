
// accessibility_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiputalk/utils/rounded_card.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {
  double fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadFontSizePreference();
  }

  Future<void> _loadFontSizePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fontSize = prefs.getDouble('font_size') ?? 16.0;
    });
  }

  Future<void> _saveFontSizePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', fontSize);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculamos dimensiones responsivas basadas en el tamaño de la pantalla
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

        // Ajustamos tamaños de forma responsiva
        final double titleFontSize = screenWidth * 0.06;
        final double subtitleFontSize = screenWidth * 0.04;
        final double cardRadius = screenWidth * 0.08;
        final double paddingHorizontal = screenWidth * 0.06;
        final double paddingVertical = screenHeight * 0.03;

        return Scaffold(
          body: Container(
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
              child: Column(
                children: [
                  // Header con título y botón de regreso
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingHorizontal,
                      vertical: paddingVertical,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: Navigator.of(context).pop,
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          iconSize: screenWidth * 0.06,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        SizedBox(width: screenWidth * 0.04), // Espacio entre el icono y el texto
                        Expanded(
                          child: Text(
                            'Accesibilidad',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Espacio equivalente al icono para centrar el título
                        SizedBox(width: screenWidth * 0.06 + screenWidth * 0.04),
                      ],
                    ),
                  ),
                  // Contenido principal
                  Expanded(
                    child: RoundedCard(
                      radius: cardRadius,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: paddingHorizontal,
                            vertical: paddingVertical,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Tamaño de Texto de Chat',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Slider(
                                value: fontSize,
                                min: 12.0,
                                max: 24.0,
                                divisions: 6,
                                label: '${fontSize.round()}',
                                onChanged: (value) {
                                  setState(() {
                                    fontSize = value;
                                  });
                                  _saveFontSizePreference();
                                },
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Ejemplo de texto para visualizar el tamaño',
                                style: TextStyle(fontSize: fontSize),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
