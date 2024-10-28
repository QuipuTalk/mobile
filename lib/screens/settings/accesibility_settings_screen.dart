
// accessibility_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accesibilidad'),
        backgroundColor: const Color(0xFF2D4554),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tamaño de Texto',
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
          ],
        ),
      ),
    );
  }
}
