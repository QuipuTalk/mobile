import 'package:flutter/material.dart';
import 'package:quiputalk/screens/camera/camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              onPressed: () {
                // Acción para grabar video, puedes cambiar esto según la funcionalidad que quieras
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context)=> const CameraScreen())
                );
                 
              },
              child: const Text('Grabar Video'),
            ),
            ElevatedButton(
              onPressed: () {
                // Acción para ver traducción, puedes cambiar esto según la funcionalidad que quieras
              },
              child: const Text('Ver Traducción'),
            ),
          ],
        ),
      ),
    );
  }
}
