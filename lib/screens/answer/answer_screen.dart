import 'package:flutter/material.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      iconTheme: const IconThemeData(
        color: Colors.white
      ),
      backgroundColor: const Color(0xFF2D4554) ,
      
      ),
      body: Container(
        child: const Text("Hola"),
      ),
    );
  }
}


