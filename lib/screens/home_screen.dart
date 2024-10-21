import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:quiputalk/screens/camera/camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
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
      appBar: AppBar(
        title: const Text('Quipu Talk'),
        backgroundColor: const Color(0xFF2D4554),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Bienvenido a Quipu Talk',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildButton('Grabar Video', _navigateToCameraScreen),
            const SizedBox(height: 10),
            _buildButton('Ver Traducción', _showTranslation),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isConnected ? onPressed : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF254558), // Color en hexadecimal
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      child: Text(text, style: const TextStyle(fontSize: 18)),
    );
  }
}