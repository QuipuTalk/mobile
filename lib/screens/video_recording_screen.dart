import 'package:flutter/material.dart';

class VideoRecordingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grabar Video'),
      ),
      body: Center(
        child: Icon(
          Icons.videocam,
          size: 100,
          color: Colors.blueAccent,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para grabar video
        },
        child: Icon(Icons.videocam),
      ),
    );
  }
}
