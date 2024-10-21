import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:quiputalk/screens/camera/camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Connectivity _connectivity;
  late Stream<ConnectivityResult> _connectivityStream;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    _initializeConnectivity();
    _connectivityStream.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  Future<void> _initializeConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      result = ConnectivityResult.none;
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
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
            ElevatedButton(
              onPressed: _isConnected
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraScreen()),
                );
              }
                  : null,
              child: const Text('Grabar Video'),
            ),
            ElevatedButton(
              onPressed: _isConnected
                  ? () {
                // Acción para ver traducción, puedes cambiar esto según la funcionalidad que quieras
              }
                  : null,
              child: const Text('Ver Traducción'),
            ),
          ],
        ),
      ),
    );
  }
}
