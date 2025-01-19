import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiputalk/providers/font_size_provider.dart';

class OptionWidget extends StatelessWidget {
  final String text;
  final Function() onTap;

  const OptionWidget({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos el tamaño de fuente global
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF617D8C),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          // 2. En lugar de fontSize fijo, usamos el del Provider
          style: TextStyle(
            fontSize: fontSize, // o fontSize - 2, o como quieras ajustarlo
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
