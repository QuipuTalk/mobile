import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraPermissionScreen extends StatelessWidget {
  const CameraPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         iconTheme: const IconThemeData(
        color: Colors.white
      ),
      backgroundColor: const Color(0xFF2D4554) ,
      automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF49A5DE), Color(0xFF2D4554)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[          
                const Text(
                  'Permite a Quipu acceder a la cámara',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white,),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Habilita la cámara para detectar y traducir el lenguaje de señas. '
                      'Puedes cambiar esta configuración en cualquier momento desde los ajustes de tu dispositivo.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (await Permission.camera.request().isGranted) {
                      Navigator.pop(context, true);
                    } else {
                      // Puedes manejar el caso en que el permiso sea denegado
                      Navigator.pop(context, false);
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Acceso a la cámara'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                    backgroundColor: const Color(0xFF9DC8E4), // Color de fondo del botón
                    foregroundColor: Colors.black, // Color del texto y del ícono
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
              ],
            ),
          ),
        ]
      ),   
      
    );
  }
}
