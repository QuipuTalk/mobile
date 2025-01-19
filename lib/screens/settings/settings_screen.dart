import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiputalk/utils/rounded_card.dart';
import 'voice_settings_screen.dart';
import 'package:quiputalk/screens/settings/accesibility_settings_screen.dart';
import 'package:quiputalk/screens/settings/communication_style_settings_screen.dart';

// Importa tu FontSizeProvider
import 'package:quiputalk/providers/font_size_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el size de pantalla y el provider
    final size = MediaQuery.of(context).size;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    // 2. Definimos nuestros tamaños base y los escalamos
    //    Por ejemplo, usas 24 para el título y 16 para las ListTiles
    final double baseTitleSize = 24.0;
    final double scaledTitleSize = baseTitleSize * (fontSizeProvider.fontSize / 16.0);

    final double baseTileSize = 16.0;
    final double scaledTileSize = baseTileSize * (fontSizeProvider.fontSize / 16.0);

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
          child: Stack(
            children: [
              // Botón "atrás"
              Positioned(
                left: 16,
                top: 16,
                child: IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              // Título centrado (sin const, para usar variables dinámicas)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Ajustes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: scaledTitleSize, // Usa el tamaño escalado
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Card principal
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: size.height * 0.85,
                child: RoundedCard(
                  height: size.height * 0.75,
                  radius: size.width * 0.1,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                      vertical: size.height * 0.04,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ListTile 1
                        ListTile(
                          leading: const Icon(Icons.accessibility_new),
                          title: Text(
                            'Accesibilidad',
                            style: TextStyle(
                              fontSize: scaledTileSize, // Escala el texto
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                const AccessibilitySettingsScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        // ListTile 2
                        ListTile(
                          leading: const Icon(Icons.record_voice_over),
                          title: Text(
                            'Voz y Audio',
                            style: TextStyle(
                              fontSize: scaledTileSize,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                const VoiceSettingsScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        // ListTile 3
                        ListTile(
                          leading: const Icon(Icons.chat),
                          title: Text(
                            'Estilo de Comunicación',
                            style: TextStyle(
                              fontSize: scaledTileSize,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                const CommunicationStyleSettingsScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
