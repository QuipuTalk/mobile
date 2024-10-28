import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiputalk/utils/rounded_card.dart';

class CommunicationStyleSettingsScreen extends StatefulWidget {
  const CommunicationStyleSettingsScreen({super.key});

  @override
  State<CommunicationStyleSettingsScreen> createState() => _CommunicationStyleSettingsScreenState();
}

class _CommunicationStyleSettingsScreenState extends State<CommunicationStyleSettingsScreen> {
  String? selectedStyle;
  bool isLoading = true;

  final List<String> styles = [
    'Neutral',
    'Formal',
    'Informal',
  ];

  @override
  void initState() {
    super.initState();
    _loadStylePreference();
  }

  Future<void> _loadStylePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedStyle = prefs.getString('communication_style') ?? styles[0];
      isLoading = false;
    });
  }

  Future<void> _saveStylePreference() async {
    if (selectedStyle != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('communication_style', selectedStyle!);
    }
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
                            'Estilo de Comunicación',
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
                              Text(
                                'Selecciona el estilo de comunicación',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: screenHeight * 0.04),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: paddingHorizontal,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(cardRadius * 0.5),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedStyle,
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    items: styles.map((style) {
                                      return DropdownMenuItem<String>(
                                        value: style,
                                        child: Text(
                                          style,
                                          style: TextStyle(
                                            fontSize: subtitleFontSize * 0.8,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedStyle = newValue;
                                        _saveStylePreference();
                                      });
                                    },
                                  ),
                                ),
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