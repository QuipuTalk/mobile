import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bienvenido a Quipu Talk',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Acción para grabar video, puedes cambiar esto según la funcionalidad que quieras
              },
              child: Text('Grabar Video'),
            ),
            ElevatedButton(
              onPressed: () {
                // Acción para ver traducción, puedes cambiar esto según la funcionalidad que quieras
              },
              child: Text('Ver Traducción'),
            ),
          ],
        ),
      ),
    );
  }
}
