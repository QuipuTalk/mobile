
import 'package:flutter/material.dart';

class HexColor {
  static Color fromHex(String hexString, {double opacity = 1.0}) {
    final buffer = StringBuffer();

    int alpha = (opacity * 255).toInt();
    String alphaHex = alpha.toRadixString(16).padLeft(2, '0');

    buffer.write(alphaHex);
    buffer.write(hexString.replaceFirst('#', ''));

    return Color(int.parse(buffer.toString(), radix: 16));
  }
}