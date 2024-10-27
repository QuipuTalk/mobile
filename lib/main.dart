import 'package:flutter/material.dart';
import 'package:quiputalk/screens/splash_screen.dart'; // Asegúrate de importar tu SplashScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quipu Talk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'LexendDeca',
        useMaterial3: true,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false, // Esta línea desactiva el banner de debug
    );
  }
}
