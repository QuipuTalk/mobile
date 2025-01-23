import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:quiputalk/providers/font_size_provider.dart';

import 'package:quiputalk/providers/camera_controller_service.dart';
import 'package:quiputalk/routes/conversation_navigator.dart';
import 'package:quiputalk/screens/camera/camera_screen.dart';
import 'package:quiputalk/screens/tutorial_screen.dart';
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
  bool _checkedFirstTime = false; // Para saber si ya cargamos la preferencia

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _testConnection();
    _checkFirstTime();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _testConnection() async {
    BackendService backendService = BackendService();
    await backendService.testBackendConnection();
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

  /// Verifica si es la primera vez que inicia la app
  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool? firstTime = prefs.getBool('first_time');

    if (firstTime == null || firstTime == true) {
      // Marcamos que ya no es primera vez
      await prefs.setBool('first_time', false);

      // Mostramos el tutorial en cuanto la pantalla se haya construido
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TutorialScreen()),
        );
      });
    } else {
      // No es la primera vez, así que simplemente mostramos la Home normal
      setState(() {
        _checkedFirstTime = true;
      });
    }
  }

  void _showNoInternetNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'No hay conexión a Internet. Las funciones de traducción no estarán disponibles.'),
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

  void _navigateToCamera() {
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
    // Si todavía no sabemos si es la primera vez,
    // podemos mostrar un loader o un Container vacío
    if (!_checkedFirstTime) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Ya no es la primera vez, construimos la UI normal
    final size = MediaQuery.of(context).size;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    final double baseTitleSize = size.width * 0.09;
    final double scaledTitleSize = baseTitleSize * (fontSizeProvider.fontSize / 16.0);

    final double baseButtonTextSize = size.width * 0.04;
    final double scaledButtonTextSize = baseButtonTextSize * (fontSizeProvider.fontSize / 16.0);

    final heightPadding = size.height * 0.02;
    final buttonWidth = size.width * 0.6;

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
                  radius: size.width * 0.1,
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

                          // Imagen normal de Home
                          Image.asset(
                            'assets/welcome_image_2.png',
                            height: size.height * 0.25,
                            width: size.width * 0.8,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: heightPadding * 1.5),

                          // Botón "Traducción de LSP"
                          SizedBox(
                            width: buttonWidth,
                            child: _buildButton(
                              text: 'Traducción de LSP',
                              icon: Icons.handshake_outlined,
                              onPressed: _navigateToCamera,
                              color: HexColor.fromHex("#FF5034"),
                              fontSize: scaledButtonTextSize,
                            ),
                          ),
                          SizedBox(height: heightPadding),

                          // Botón "Ajustes"
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

  /// Botón reutilizable
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
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Icon(
            icon,
            color: Colors.white,
            size: fontSize + 4.0,
          ),
        ],
      ),
    );
  }
}
