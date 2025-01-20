import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiputalk/utils/rounded_card.dart';

class CommunicationStyleSettingsScreen extends StatefulWidget {
  const CommunicationStyleSettingsScreen({super.key});

  @override
  State<CommunicationStyleSettingsScreen> createState() =>
      _CommunicationStyleSettingsScreenState();
}

class _CommunicationStyleSettingsScreenState
    extends State<CommunicationStyleSettingsScreen> {
  String? selectedStyle;
  bool isLoading = true;

  // Esta es tu lista de estilos, con 'key', 'label' y 'image'.
  final List<Map<String, String>> styleOptions = [
    {
      'key': 'neutral',
      'label': 'Neutral',
      'image': 'assets/images/neutral.png', // Ajusta la ruta si es necesario
    },
    {
      'key': 'formal',
      'label': 'Formal',
      'image': 'assets/images/formal.png',
    },
    {
      'key': 'informal',
      'label': 'Informal',
      'image': 'assets/images/informal.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStylePreference();
  }

  // Cargamos el estilo desde SharedPreferences
  Future<void> _loadStylePreference() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedStyle = prefs.getString('communication_style')?.toLowerCase();

    // Verificamos si existe en 'styleOptions'. De lo contrario, ponemos por defecto el primero.
    final allKeys = styleOptions.map((option) => option['key']).toList();
    setState(() {
      selectedStyle = allKeys.contains(savedStyle)
          ? savedStyle
          : styleOptions[0]['key'];
      isLoading = false;
    });
  }

  // Guardamos el estilo seleccionado en SharedPreferences
  Future<void> _saveStylePreference() async {
    if (selectedStyle != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('communication_style', selectedStyle!);
    }
  }

  // Widget que construye la "tarjeta" de cada estilo
  Widget _buildStyleCard(
      String styleKey,
      String label,
      String imageAsset,
      double subtitleFontSize,
      ) {
    final bool isSelected = (styleKey == selectedStyle);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedStyle = styleKey;
          _saveStylePreference();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen
            Image.asset(
              imageAsset,
              height: 80, // Ajusta el tamaño de la imagen según tu diseño
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            // Etiqueta
            Text(
              label,
              style: TextStyle(
                fontSize: subtitleFontSize,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blueGrey : Colors.black,
              ),
            ),
            // Icono de check solo si está seleccionado
            if (isSelected) ...[
              const SizedBox(height: 8),
              const Icon(Icons.check_circle, color: Colors.blue),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Cálculo responsivo
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;

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
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          iconSize: screenWidth * 0.06,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        SizedBox(width: screenWidth * 0.04),
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
                        SizedBox(
                            width: screenWidth * 0.06 +
                                screenWidth * 0.04),
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

                              // Mostramos las tarjetas para cada estilo
                              for (var option in styleOptions)
                                _buildStyleCard(
                                  option['key']!,
                                  option['label']!,
                                  option['image']!,
                                  subtitleFontSize,
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
