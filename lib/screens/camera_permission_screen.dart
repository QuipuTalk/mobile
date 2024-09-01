import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPermissionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permiso de Cámara'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Permite a Quipu acceder a la cámara',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Habilita la cámara para detectar y traducir el lenguaje de señas. '
                  'Puedes cambiar esta configuración en cualquier momento desde los ajustes de tu dispositivo.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                if (await Permission.camera.request().isGranted) {
                  Navigator.pop(context, true);
                } else {
                  // Puedes manejar el caso en que el permiso sea denegado
                  Navigator.pop(context, false);
                }
              },
              icon: Icon(Icons.camera_alt),
              label: Text('Acceso a la cámara'),
            ),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
