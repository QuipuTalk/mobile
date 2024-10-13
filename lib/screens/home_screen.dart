import 'package:flutter/material.dart';
import 'package:quiputalk/screens/camera/camera_screen.dart';

import 'camera/camera_permission_screen.dart'; // Pantalla para gestionar los permisos de cámara
import 'unused-screens/video_list_screen.dart'; // Pantalla para listar y reproducir videos grabados
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isFirstTime = true; // Indicador para saber si es la primera vez que se accede

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
              onPressed: () async {
                if (isFirstTime) {
                  await _requestCameraPermission();
                } else {
                  _navigateToVideoRecording(context);
                }
              },
              child: const Text('Grabar Video'),
            ),
            ElevatedButton(
              onPressed: () {
                // Acción para ver traducción
              },
              child: const Text('Ver Traducción'),
            ),
            ElevatedButton(
              onPressed: () {
                // Acción para ver todos los videos grabados
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoListScreen(),
                  ),
                );
              },
              child: const Text('Ver Videos Grabados'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestCameraPermission() async {
    // Navegar a la pantalla de solicitud de permisos de cámara
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraPermissionScreen(),
      ),
    );

    if (result == true) {
      // Si el usuario acepta los permisos
      setState(() {
        isFirstTime = false;
      });
      _navigateToVideoRecording(context);
    }
  }

  void _navigateToVideoRecording(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        //builder: (context) => VideoRecordingScreen(),
        builder: (context)=> const CameraScreen()
      ),
    );
  }
}
