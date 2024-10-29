import 'package:flutter/material.dart';
import 'package:quiputalk/screens/settings/settings_screen.dart';
import 'package:quiputalk/utils/hexadecimal_color.dart';

class ResponseDisplayScreen extends StatelessWidget {
  final String response;

  const ResponseDisplayScreen({Key? key, required this.response}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _navigateToSettings() async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D4554),
        title: const Text('Respuesta Personalizada'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              _navigateToSettings();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Cambiado de center a start
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'Respuesta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Card(
                color: HexColor.fromHex('E8F5FB'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      response,
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60), // Reducido de 40 a 16
            Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB5050),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Volver a grabar', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10), // Espacio entre los botones
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF607D8B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Terminar conversación', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
