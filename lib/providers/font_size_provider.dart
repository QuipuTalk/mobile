import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider extends ChangeNotifier {
  double _fontSize = 16.0; // valor por defecto

  FontSizeProvider() {
    _loadFontSizeFromPrefs(); // Cargar de SharedPreferences apenas se cree
  }

  double get fontSize => _fontSize;

  // Cuando se cambie el fontSize, avisamos a todos los widgets que lo usen
  Future<void> setFontSize(double newFontSize) async {
    _fontSize = newFontSize;
    notifyListeners(); // Reconstruye la UI donde se use

    // Guardamos el valor en SharedPreferences para que persista
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', newFontSize);
  }

  // Carga inicial desde SharedPreferences
  Future<void> _loadFontSizeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedFontSize = prefs.getDouble('font_size');
    if (storedFontSize != null) {
      _fontSize = storedFontSize;
      notifyListeners();
    }
  }
}
