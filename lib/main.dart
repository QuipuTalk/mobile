import 'package:flutter/material.dart';
import 'package:quiputalk/providers/conversation_service.dart';
import 'package:quiputalk/providers/session_service.dart';
import 'package:quiputalk/screens/splash_screen.dart';
// Importa tu nuevo provider
import 'package:provider/provider.dart';
import 'package:quiputalk/providers/font_size_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionService()),
        ChangeNotifierProvider(create: (_) => ConversationService()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      debugShowCheckedModeBanner: false,
    );
  }
}
