import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:quiputalk/screens/camera/camera_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      body: SafeArea(
        child: Stack(
          children: [
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if(_isFirstTime) ...[
                        const Text(
                          'Quipu Talk',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D4554),
                          ),
                        ),
                        Image.asset(
                          'assets/welcome_image.png',
                          height: 150,
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
                        const SizedBox(height: 50),
                        Image.asset(
                          'assets/welcome_image_2.png', // Asegúrate de tener la imagen en el directorio correcto
                          height: 150,
                        ),
                      ],
                      const Spacer(),
                      _buildButton('Traducción de LSP', Icons.handshake_outlined, _navigateToCameraScreen, Colors.red),
                      const SizedBox(height: 10),
                      _buildButton('Ajustes', Icons.settings, () {}, const Color(0xFF607D8B)),
                    ],
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      onPressed: _isConnected ? onPressed : null,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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