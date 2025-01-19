import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// Importamos Provider y nuestro FontSizeProvider
import 'package:provider/provider.dart';
import 'package:quiputalk/providers/font_size_provider.dart';

import 'package:quiputalk/providers/camera_controller_service.dart';
import 'package:quiputalk/routes/conversation_navigator.dart';
import 'package:quiputalk/screens/camera/camera_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:quiputalk/utils/hexadecimal_color.dart';
import 'package:quiputalk/screens/settings/settings_screen.dart';
import 'package:quiputalk/utils/rounded_card.dart';
import '../providers/backend_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  bool _isFirstTime = true;

  void _testConnection() async {
    BackendService backendService = BackendService();
    await backendService.testBackendConnection();
  }

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _testConnection();
    _checkFirstTime();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initializeConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _updateConnectionStatus(ConnectivityResult.none);
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final bool previousConnectionStatus = _isConnected;
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });

    if (!_isConnected && previousConnectionStatus != _isConnected) {
      _showNoInternetNotification();
    }
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? firstTime = prefs.getBool('first_time');
    if (firstTime == null || firstTime == true) {
      setState(() {
        _isFirstTime = true;
      });
      await prefs.setBool('first_time', false);
    } else {
      setState(() {
        _isFirstTime = false;
      });
    }
  }

  void _showNoInternetNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No hay conexión a Internet. Las funciones de traducción no estarán disponibles.'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Salir'),
          content: const Text('¿Deseas salir de la aplicación?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToCamera(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
        settings: const RouteSettings(name: 'CameraScreen'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el tamaño de pantalla y el fontSize del provider
    final size = MediaQuery.of(context).size;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context, listen: true);

    // 2. Si quieres combinar tu "responsivo" + tamaño ajustable:
    //    Multiplicamos lo que tenías por (fontSize / 16)
    final double baseTitleSize = size.width * 0.09;
    final double scaledTitleSize = baseTitleSize * (fontSizeProvider.fontSize / 16.0);

    final double baseSubTitleSize = size.width * 0.06;
    final double scaledSubTitleSize = baseSubTitleSize * (fontSizeProvider.fontSize / 16.0);

    // Para los botones, puedes usarlo directamente o combinar
    // con la parte responsiva. Lo mantengo simple por ahora.
    final double baseButtonTextSize = size.width * 0.04;
    final double scaledButtonTextSize = baseButtonTextSize * (fontSizeProvider.fontSize / 16.0);

    final heightPadding = size.height * 0.02; // 2% de la altura
    final buttonWidth = size.width * 0.6;    // 60% del ancho de la pantalla

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
            stops: [0.0, 1.0],
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
                  onPressed: _showExitDialog,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              // Card principal
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: RoundedCard(
                  height: size.height * 0.85,
                  radius: size.width * 0.1, // 10% del ancho para el radio
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                        vertical: heightPadding,
                      ),
                      child: Column(
                        children: <Widget>[
                          // Título "Quipu Talk"
                          Text(
                            'Quipu Talk',
                            style: TextStyle(
                              fontSize: scaledTitleSize,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D4554),
                            ),
                          ),
                          SizedBox(height: heightPadding),

                          // Si es la primera vez: imagen "welcome_image"
                          if (_isFirstTime) ...[
                            Image.asset(
                              'assets/welcome_image.png',
                              height: size.height * 0.25,
                              width: size.width * 0.8,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: heightPadding),
                            Text(
                              'Tutorial de Bienvenida',
                              style: TextStyle(
                                fontSize: scaledSubTitleSize,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2D4554),
                              ),
                            ),
                          ] else ...[
                            SizedBox(height: heightPadding),
                            Image.asset(
                              'assets/welcome_image_2.png',
                              height: size.height * 0.25,
                              width: size.width * 0.8,
                              fit: BoxFit.contain,
                            ),
                          ],

                          SizedBox(height: heightPadding * 1.5),

                          // Primer botón
                          SizedBox(
                            width: buttonWidth,
                            child: _buildButton(
                              text: 'Traducción de LSP',
                              icon: Icons.handshake_outlined,
                              onPressed: _navigateToCamera,
                              color: HexColor.fromHex("#FF5034"),
                              fontSize: scaledButtonTextSize, // Enviado para ajustar
                            ),
                          ),

                          SizedBox(height: heightPadding),

                          // Segundo botón
                          SizedBox(
                            width: buttonWidth,
                            child: _buildButton(
                              text: 'Ajustes',
                              icon: Icons.settings,
                              onPressed: _navigateToSettings,
                              color: HexColor.fromHex("#768893"),
                              fontSize: scaledButtonTextSize,
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
  }

  /// Botón que recibe `fontSize` para ajustar el texto
  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    required double fontSize,
  }) {
    return ElevatedButton(
      onPressed: _isConnected ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.025,
          horizontal: MediaQuery.of(context).size.width * 0.05,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize, // ajustado
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Icon(
            icon,
            color: Colors.white,
            size: fontSize + 4.0, // Ajuste para el ícono
          ),
        ],
      ),
    );
  }
}
