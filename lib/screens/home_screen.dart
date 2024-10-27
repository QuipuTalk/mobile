import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:quiputalk/screens/camera/camera_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:quiputalk/utils/hexadecimal_color.dart';

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

  void _showTranslation() {
    // Implement the translation viewing functionality here
    print('Viewing translation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
/*      appBar: AppBar(
        title: const Text('Quipu Talk'),
        backgroundColor: const Color(0xFF2D4554),
      ),*/
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF49A5DE),
              Color(0xFF2D4554),
            ],
            stops: [0.0,1.0]
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
                    icon: const Icon(Icons.arrow_back,color: Colors.white)
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: RoundedCard(
                  height: MediaQuery.of(context).size.height * 0.85,
                  radius: 40,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Quipu Talk',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D4554),
                          ),
                        ),
                        const SizedBox( height: 15),
                        if(_isFirstTime) ...[
                          Image.asset(
                            'assets/welcome_image.png',
                            height: 200,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Tutorial de Bienvenida',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D4554),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 30),
                          Image.asset(
                            'assets/welcome_image_2.png', // Asegúrate de tener la imagen en el directorio correcto
                            height: 200,
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          child: _buildButton(
                              'Traducción de LSP',
                              Icons.handshake_outlined,
                              _navigateToCameraScreen,
                              HexColor.fromHex("#FF5034")),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 200,
                          child: _buildButton(
                              'Ajustes',
                              Icons.settings, () {},
                              HexColor.fromHex("#768893")),
                        ),

                      ],
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
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Añadido para evitar que el Row tome todo el espacio
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible( // Añadido Flexible para permitir que el texto se ajuste si es necesario
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: Colors.white),
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