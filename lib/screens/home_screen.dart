import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:quiputalk/screens/camera/camera_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:quiputalk/utils/hexadecimal_color.dart';
import 'package:quiputalk/screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  bool _isFirstTime = true;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
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

  void _navigateToCameraScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla
    final size = MediaQuery.of(context).size;
    final heightPadding = size.height * 0.02; // 2% de la altura
    final buttonWidth = size.width * 0.6; // 60% del ancho de la pantalla

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
                stops: [0.0, 1.0]
            )
        ),
        child: SafeArea(
          child: Stack(
              children: [
                Positioned(
                  left: 16,
                  top: 16,
                  child: IconButton(
                      onPressed: _showExitDialog,
                      icon: const Icon(Icons.arrow_back, color: Colors.white)
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: RoundedCard(
                    height: size.height * 0.85,
                    radius: size.width * 0.1, // 10% del ancho para el radio
                    child: SingleChildScrollView( // Añadido para evitar overflow en pantallas pequeñas
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.08, // 8% del ancho
                          vertical: heightPadding,
                        ),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Quipu Talk',
                              style: TextStyle(
                                fontSize: size.width * 0.09, // 9% del ancho
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D4554),
                              ),
                            ),
                            SizedBox(height: heightPadding),
                            if(_isFirstTime) ...[
                              Image.asset(
                                'assets/welcome_image.png',
                                height: size.height * 0.25, // 25% de la altura
                                width: size.width * 0.8, // 80% del ancho
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: heightPadding),
                              Text(
                                'Tutorial de Bienvenida',
                                style: TextStyle(
                                  fontSize: size.width * 0.06, // 6% del ancho
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
                            SizedBox(
                              width: buttonWidth,
                              child: _buildButton(
                                'Traducción de LSP',
                                Icons.handshake_outlined,
                                _navigateToCameraScreen,
                                HexColor.fromHex("#FF5034"),
                              ),
                            ),
                            SizedBox(height: heightPadding),
                            SizedBox(
                              width: buttonWidth,
                              child: _buildButton(
                                'Ajustes',
                                Icons.settings,
                                _navigateToSettings,
                                HexColor.fromHex("#768893"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      String text, IconData icon, VoidCallback onPressed, Color color) {
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
                fontSize: MediaQuery.of(context).size.width * 0.04, // 4% del ancho
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Icon(
            icon,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.06, // 6% del ancho
          ),
        ],
      ),
    );
  }

}

class RoundedCard extends StatelessWidget {
  final Widget child;
  final double height;
  final double radius;

  const RoundedCard({
    Key? key,
    required this.child,
    this.height = 600,
    this.radius = 30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: child,
    );
  }
}